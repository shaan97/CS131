import asyncio
import logging
import re
import time
import sys
import json

# CHANGE THESE PORT NUMBERS AS NEEDED
servers = {"Alford": 8888, "Hamilton": 8889, "Welsh": 8890, "Ball": 8891, "Holiday": 8892}
friends = {
    "Alford": {"Hamilton", "Welsh"},
    "Ball": {"Holiday", "Welsh"},
    "Hamilton": {"Holiday"},
    "Welsh": {"Alford", "Ball"},
    "Holiday": {"Ball", "Hamilton"}
}


class Server(asyncio.Protocol):
    def __init__(self, name, port, friends, loop):
        logging.debug("Server initializing...")
        self.name = name
        self.port = port
        self.friends = friends
        self.loop = loop
        self.locations = {}

    async def __call__(self, reader, writer):
        data = await reader.read(10000)
        request = data.decode()
        logging.info("%s received message %s" % (self.name, request))
        await self.serve_request(request, writer)

    async def serve_request(self, request, writer):
        time_stamp = time.time()
        msg = request.split()
        reply = ""
        if len(msg) == 0:
            reply = "? %s" % request
        elif msg[0] == "IAMAT":

            is_float = True
            try:
                if len(msg) == 4:
                    float(msg[3])
            except ValueError:
                is_float = False

            if len(msg) == 4 and re.match(r'^[\+-]\d+\.\d+[\+-]\d+\.\d+$', msg[2]) and is_float and float(msg[3]) >= 0:
                reply = "AT %s %s %s" % (self.name, time_stamp - float(msg[3]), request[request.find(msg[1]):])

                if msg[1] in self.locations:
                    _, _, last_time = self.locations[msg[1]]
                    if float(last_time.split()[-1]) <= float(msg[3]):
                        self.locations[msg[1]] = (self.name, time_stamp - float(msg[3]), request[request.find(msg[1]):])
                        asyncio.ensure_future(self.flood(reply, {}), loop=self.loop)
                else:
                    self.locations[msg[1]] = (self.name, time_stamp - float(msg[3]), request[request.find(msg[1]):])
                    asyncio.ensure_future(self.flood(reply, {}), loop=self.loop)


            else:
                reply = "? %s" % request

        elif msg[0] == "WHATSAT":
            # Use Google Places API
            is_int = True
            try:
                if len(msg) == 4:
                    int(msg[2])
                    int(msg[3])
            except ValueError:
                is_int = False

            if len(msg) != 4 or msg[1] not in self.locations or not is_int or int(msg[2]) > 50 or int(msg[2]) < 0 or int(msg[3]) > 20 or int(msg[3]) < 0:
                reply = "? %s" % request
            else:
                _, _, req = self.locations[msg[1]]
                location = ','.join(re.findall(r'[+-][0-9]+\.[0-9]+', req.split()[1]))
                reply = ("AT %s %s %s\n" % self.locations[msg[1]]) + (await self.google_places_query(location, int(msg[2]), int(msg[3])))

        elif msg[0] == "AT":

            if msg[3] not in self.locations:
                self.locations[msg[3]] = (msg[1], msg[2], request[request.find(msg[3]):request.rfind(msg[-1])])
                blacklist = {msg[-1]}
            else:
                _, _, original_msg = self.locations[msg[3]]
                original_msg = original_msg.split()
                if float(original_msg[-1]) < float(msg[-2]):
                    self.locations[msg[3]] = (msg[1], msg[2], request[request.find(msg[3]):request.rfind(msg[-1])])
                else:
                    return
                blacklist = {msg[1], msg[-1]}

            asyncio.ensure_future(self.flood(' '.join(msg[:-1]), blacklist), loop=self.loop)
            return
        else:
            reply = "? %s" % request

        logging.debug("Sending: '%s'" % reply)
        await self.send(reply, writer)
        writer.close()

    async def google_places_query(self, location, radius, bound):
        query = ('GET /maps/api/place/nearbysearch/json?location={location}&radius={radius}&key=AIzaSyAlKtZl_NC00gcwy6Pejf7efflWAH8e5TI HTTP/1.1\r\n'
                 'Host: {hostname}:443\r\n'
                 'Connection: close\r\n'
                 '\r\n').format(location=location, radius=radius, hostname="maps.googleapis.com")

        logging.debug("Sending following HTTP/1.1:\n%s" % query)
        reader, writer = await asyncio.open_connection("maps.googleapis.com", 443, ssl=True)
        writer.write(query.encode())
        await writer.drain()

        _response = await reader.read()
        writer.close()
        response = _response.decode()
        logging.debug("Got response:\n%s" % response)

        response_json = json.loads(response[response.find("{"):])
        response_json['results'] = len(response_json['results']) <= bound and response_json['results'] or response_json['results'][:bound]
        return json.dumps(response_json, sort_keys=True, indent=4, separators=(',', ': ')) + "\n\n"

    async def flood(self, data, blacklist):
        forward = ("%s %s" % (data, self.name)).encode()
        for friend, port in self.friends.items():
            if friend in blacklist:
                continue
            logging.debug("Forwarding '%s' to %s" % (forward, friend))
            try:
                _, writer = await asyncio.open_connection('127.0.0.1', port, loop=self.loop)
                writer.write(forward)
                await writer.drain()
                writer.close()
            except ConnectionRefusedError:
                logging.warning("Refused connection with %s" % friend)
            except TimeoutError:
                logging.warning("Timeout with %s" % friend)

    async def send(self, response, writer):
        writer.write(response.encode())
        await writer.drain()


if __name__ == "__main__":
    server_name = sys.argv[-1]
    port = servers[server_name]

    logging.basicConfig(level=logging.DEBUG)
    loop = asyncio.get_event_loop()
    coro = asyncio.start_server(Server(server_name, port, {friend: servers[friend] for friend in friends[server_name]}, loop), '127.0.0.1', port, loop=loop)
    server = loop.run_until_complete(coro)

    print('Serving on {}'.format(server.sockets[0].getsockname()))
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        pass

    server.close()
    loop.run_until_complete(server.wait_closed())
    loop.close()