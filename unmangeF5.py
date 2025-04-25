import requests
# pip install orionsdk
from orionsdk import SwisClient
from dotenv import load_dotenv
import os
from datetime import datetime, timezone, timedelta

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

print("Getting F5 Devices:")
results = swis.query("SELECT top 10 NodeID, IPAddress, Caption, vendor, UnManaged FROM Orion.Nodes n where Vendor like 'F5%'")

starttime = datetime.now(timezone.utc)
endtime = starttime + timedelta(hours=1)

for row in results['results']:
    netObjectId  = 'N:{}'.format(row['NodeID'])
    swis.invoke('Orion.Nodes', 'Unmanage', netObjectId , starttime, endtime, False)
    print("Unmanaging {NodeID:<5}: {Caption}".format(**row))