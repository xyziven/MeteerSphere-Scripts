# MeteerSphere-Scripts
Shell Scripts for MeterSphere Integrations. 

Prerequisites:
 - Linux only. Tested on CentOS. Ubuntu/RHEL is supposed to be supported as well. 
 - jq is instlalled
 - there's blank in the project name or test plan name, please use double quota ""

v3.x is to call MeterSphere 3.x to trigger Test Plans or Test Plan Groups. 
- Usage of runMSv3TestPlan.sh
  This is the script to trigger MS TestPlan.
  - Usage:
    -   $ bash runMSv3TestPlan.sh <MS-Server-URL> accessKey secretKey "Project Name" "Test Plan Name"
     -  e.g.
        $ bash runMSv3TestPlan.sh http://<MS-Server-IP-Address>:8081  accessKey secretKey "My Test Project" "My Test Plan"
  
- Usage of runMSv3PlanGroup.sh:  
  This is the script to trigger MS TestPlanGroup.
 -  Usage:
    -  $ bash runMSv3PlanGroup.sh  MS-Server-URL accessKey secretKey "Project Name" "Test Plan Name" PARALLEL
    -  e.g.
     -  $ bash runMSv3PlanGroup.sh   http://MS-Server-IP-Address:8081 accessKey secretKey "Project Name" "Test Plan Name" PARALLEL
     - $ bash runMSv3PlanGroup.sh   http://MS-Server-IP-Address:8081 accessKey secretKey "Project Name" "Test Plan Name" SERIAL

   Note: TestPlanGroup support the set of runMode. It has to be SERIAL or PARALLEL. 
  
v2.x is to call MeterSphere 2.x to trigger Test Plans.
- Usage of runMSv2TestPlan0925.sh: 
  Usage:
   - $ bash runMSv2TestPlan0925.sh accessKey secretKy projectName envName testPlanName HOST_URL resourcePoolName userId
   - e.g. $ bash runMSv2TestPlan0925.sh accessKey secretKy projectName envName testPlanName http://MS-Server-IP-Address:8081 resourcePoolName userId

   - Note: 
    - resourcePoolName requires the query privilege of resource pool. (查询测试资源池权限)
    - userId could be grabbed from Users page（用户页面）
   



