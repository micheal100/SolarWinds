import requests
# pip install orionsdk
from orionsdk import SwisClient
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()
username = os.getenv('user')
password = os.getenv('password')
server = os.getenv('server')

verify = False
if not verify:
    from requests.packages.urllib3.exceptions import InsecureRequestWarning
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)


swis = SwisClient(server, username, password)

print("Query Test:")
results = swis.query("SELECT top 10 NodeID, IPAddress, Caption, vendor, UnManaged FROM Orion.Nodes n where Vendor like 'F5%'")

for row in results['results']:
    print("{NodeID:<5}: {Caption}".format(**row))