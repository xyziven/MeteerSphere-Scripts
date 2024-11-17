# MeteerSphere-Scripts
Shell Scripts for MeterSphere Integrations. 

Prerequisites:
 - Linux only. Tested on CentOS. Ubuntu/RHEL are supposed to be supported as well. 
 - jq is instlalled on the system or the enviroment where the script to run. 
 - If there's blank in the project name or test plan name, please use double quota ""

v3.x is to call MeterSphere 3.x to trigger Test Plans or Test Plan Groups. 
- Usage of runMSv3TestPlan.sh
  This is the script to trigger MS TestPlan.
  - Usage:
    -   $ bash runMSv3TestPlan.sh MS-Server-URL accessKey secretKey "Project Name" "Test Plan Name"
     -  e.g.
        $ bash runMSv3TestPlan.sh http://MS-Server-IP-Address:8081  accessKey secretKey "My Test Project" "My Test Plan"
  
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
      
   ================================================
   使用说明：
   通过Shell调用MeterSphere API 以触发 测试计划或计划组的执行。
  
   前提条件：
 - 只支持Linux. 已在CentOS 7.x验证，其他Linux如 Ubuntu/RHEL应该也可以运行；
 - 脚本依赖jq，在运行环境中已安装jq；
 - 如果项目名称或测试计划名称等有空格，请用双引号引起来。

目录v3.x 是调用 MeterSphere 3.x 的脚本. 
-  runMSv3TestPlan.sh 用于触发 3.x的测试计划
  - 用法:
    -   $ bash runMSv3TestPlan.sh MS-Server-URL accessKey secretKey "Project Name" "Test Plan Name"
     -  如：
        $ bash runMSv3TestPlan.sh http://MS-Server-IP-Address:8081  accessKey secretKey "My Test Project" "My Test Plan"
  
- runMSv3PlanGroup.sh 用于触发 3.x的计划组
 -  用户:
    -  $ bash runMSv3PlanGroup.sh  MS-Server-URL accessKey secretKey "Project Name" "Test Plan Name" PARALLEL
    -  如：
     - $ bash runMSv3PlanGroup.sh   http://MS-Server-IP-Address:8081 accessKey secretKey "Project Name" "Test Plan Name" PARALLEL  （并行执行）
     - $ bash runMSv3PlanGroup.sh   http://MS-Server-IP-Address:8081 accessKey secretKey "Project Name" "Test Plan Name" SERIAL （串行执行）

    - 注: 计划组执行时，可选择串行或并行执行，因此多了个runMode参数，该参数值只能为 SERIAL 或 PARALLEL。
  
目录v2.x 是调用MeterSphere 2.x 测试计划的脚本.
- runMSv2TestPlan0925.sh 用法：
   - $ bash runMSv2TestPlan0925.sh accessKey secretKy projectName envName testPlanName HOST_URL resourcePoolName userId
   - e.g. $ bash runMSv2TestPlan0925.sh accessKey secretKy projectName envName testPlanName http://MS-Server-IP-Address:8081 resourcePoolName userId

   - 注: 
    - resourcePoolName 是资源池名称，运行该脚本的用户需要有 “查询测试资源池”的权限
    - userId 可以从用户页面查找执行脚本的用户Id
