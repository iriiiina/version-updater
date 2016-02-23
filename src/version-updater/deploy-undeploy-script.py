import sys

connect(userConfigFile='user-name.secure',userKeyFile='user-pass.secure', url='t3://'+ADMIN_SERVER_IP+':'+ADMIN_SERVER_PORT)

NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'

if sys.argv[2] == "deploy":
  try:
    import java.util as util
    import java.io as javaio
    properties = util.Properties()
    propertiesfile = javaio.FileInputStream("cluster.properties")
    properties.load(propertiesfile)
    deploy(sys.argv[1], '/home/wls/'+sys.argv[1]+'.war', properties.getProperty(sys.argv[1]))
    print GREEN,"\tOK: new version of",sys.argv[1],"is deployed",NONE
  except:
    print RED,"\tERROR: can't deploy new version of",sys.argv[1],": ", sys.exc_info()[0], sys.exc_info()[1],NONE
elif sys.argv[2] == "undeploy":
  try:
    undeploy(sys.argv[1])
    print GREEN,"\tOK: old version of",sys.argv[1],"is undeployed",NONE
  except:
    print YELLOW,"\tERROR: can't undeploy old version of",sys.argv[1],": ",sys.exc_info()[0], sys.exc_info()[1],NONE
elif sys.argv[2] == "list":
  appList = []
  appPath = {}
  cd('/')
  domainConfig()
  for app in cmo.getAppDeployments():
    cd('/')
    appName = app.getName()
    appList.append(appName)
    cd('AppDeployments/' + appName )
    appPath[appName]=get('SourcePath')
  domainRuntime()
  cd('AppRuntimeStateRuntime/AppRuntimeStateRuntime')
  while appList:
    appName=appList.pop(0)
    state=cmo.getIntendedState(appName)
    print appName.ljust(30), state.ljust(20), appPath.get(appName)

disconnect()
exit()