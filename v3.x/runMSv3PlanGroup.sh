#!/bin/bash
######################################################
#### This script is to trigger MeterSphere PlanGroup #
#### Compatible with MS V3.x                         #
#### Author xyziven                                  #
#### 2024.11.17  Initial version                     #
####                                                 #
####                                                 #
#### Copyright @2024                                 #
######################################################
usage()
{
 echo Usage: sh $0 HOST_URL accessKey secretKy projectName testPlanGroupName runMode
 echo "runMode must be SERIAL or PARALLEL"
 exit 1
}

if [ $# -ne 6 ]; then
  usage
else
  HOST_URL=${1}
  accessKey=${2}
  secretKey=${3}
  projectName=${4}
  planGroupName=${5} 
  runMode=${6}
fi

if [[ $runMode != "SERIAL" && $runMode != "PARALLEL" ]];then
  echo "runMode must be SERIAL or PARALLEL"
  exit 1;
fi

projectId="projectId"
planGroupId="planGroupId"
reportURL="reportURL"
reportId="retrieveReportId"
runMode="SERIAL"

keySpec=$(echo -n "${secretKey}" | od -A n -t x1 | tr -d ' ')
iv=$(echo -n "${accessKey}" | od -A n -t x1 | tr -d ' ')
currentTimeMillis=$(date +%s000)
seed=${accessKey}\|$currentTimeMillis
signature=$(printf %s "${seed}" | openssl enc -e -aes-128-cbc -base64 -K ${keySpec} -iv ${iv})

#echo "signature: $signature"

# get Project ID through project name
getProjectId()
{
    BODY='{"current": 1,"pageSize": 100,"sort": {},"keyword": "","viewId": "","combineSearch": {"searchMode": "AND","conditions": []},"filter":{}}'

#    echo "CMD is: curl -k -XPOST -s -H \"accesskey: ${accessKey}\" -H \"signature: ${signature}\" -H \"Content-Type: application/json\" ${HOST_URL}/system/project/page -d \"${BODY}\""
    RESULT=$(curl -k -XPOST -s -H "accesskey: ${accessKey}" -H "signature: ${signature}" -H "Content-Type: application/json" ${HOST_URL}/system/project/page -d "${BODY}")
    
#    echo "Project query Result: ${RESULT}"
    projectId=$(printf '%s\n' "${RESULT}" | jq '.data.list[] | select(.name == "'"${projectName}"'")' |jq -r .id)
#    echo "projectId is: $projectId"
}


# get Test-Plan-Group ID through TestPlanGroup name
getPlanGroupId()
{
    BODY='{"current":1,"pageSize":500,"sort":{},"keyword":"","viewId":"","combineSearch":{"searchMode":"AND","conditions":[]},"type":"GROUP","moduleIds":[],"projectId":'$projectId',"excludeIds":[],"selectAll":false,"selectIds":[],"filter":{},"combine":{}}'
#    echo "query plan group id CMD is: curl -k -XPOST -s -H \"accesskey: ${accessKey}\" -H \"signature: ${signature}\" -H \"Content-Type: application/json\" ${HOST_URL}/test-plan/page -d "${BODY}""
    RESULT=$(curl -k -XPOST -s -H "accesskey: ${accessKey}" -H "signature: ${signature}" -H "Content-Type: application/json" ${HOST_URL}/test-plan/page -d "${BODY}")
    
   # echo "Query Result of PlanGroup Id: ${RESULT}"
    planGroupId=$(printf '%s\n' "${RESULT}" | jq '.data.list[] | select(.name == "'"${planGroupName}"'")' |jq -r .id)
}



# Run PlanGroup
runPlanGroup() 
{
    BODY='{"executeId":'${planGroupId}',"runMode":"'${runMode}'","executionSource":"API"}'
    RESULT=$(curl -k -s -XPOST -H "accesskey: ${accessKey}" -H "signature: ${signature}" -H "Content-Type: application/json" ${HOST_URL}/test-plan-execute/single -d "${BODY}")
    
#    echo "planGroup return Result: ${RESULT}"
    
    sleep 5
    reportId=$(printf '%s\n' "${RESULT}" | jq -r .data )
    
    echo " Report Id is: $reportId"
}

# get Test-Plan-Group report details
getReportDetails()
{
#    echo "query report detail CMD is: curl -k -XGET -s -H \"accesskey: ${accessKey}\" -H \"signature: ${signature}\" -H \"Content-Type: application/json\" ${HOST_URL}/test-plan/get/${reportId}"
    RESULT=$(curl -k -XGET -s -H "accesskey: ${accessKey}" -H "signature: ${signature}" -H "Content-Type: application/json" ${HOST_URL}/test-plan/report/get/${reportId})
#    echo "REsult: ${RESULT}"
    STATUS=$(echo $RESULT |jq -r ".data.resultStatus")
    while ([ "$STATUS" == "-" ] || [ "$STATUS" == "" ])
    do
      echo " STATUS: $STATUS RUNNING. Waiting for 5 seconds ... "
    #  echo " The TestPlanGroup ${planGroupName} is still RUNNING, waiting for 5 seconds. "
      sleep 5
      STATUS=$(curl -k -XGET -s -H "accesskey: ${accessKey}" -H "signature: ${signature}" -H "Content-Type: application/json" ${HOST_URL}/test-plan/report/get/${reportId} |jq -r ".data.resultStatus")
    done    
    echo " Status: #${STATUS}#"
    ### Now Retrieve the Report again to make sure to get the Details 
    RESULT=$(curl -k -XGET -s -H "accesskey: ${accessKey}" -H "signature: ${signature}" -H "Content-Type: application/json" ${HOST_URL}/test-plan/report/get/${reportId})
#    echo "group result: ${RESULT}"
    STATUS=$(echo $RESULT |jq -r ".data.resultStatus")
    if [[ $STATUS == "ERROR" ]];then
      STATUS="FAIL"
    fi
    echo " The Execution of testPlan \"${planGroupName}\" completed with $STATUS."
    ReportName=$(echo $RESULT |jq -r ".data.name")
    
    passThreshold=$(echo $RESULT |jq -r ".data.passThreshold")
    passRate=$(echo $RESULT |jq -r ".data.passRate")
    executeRate=$(echo $RESULT |jq -r ".data.executeRate")
	
    caseTotal=$(echo $RESULT |jq -r ".data.caseTotal")
    apiCaseTotal=$(echo $RESULT |jq -r ".data.apiCaseTotal")
    apiScenarioTotal=$(echo $RESULT |jq -r ".data.apiScenarioTotal")
    planCount=$(echo $RESULT |jq -r ".data.planCount")
    passPlanCount=$(echo $RESULT |jq -r ".data.passCountOfPlan")
    failedPlanCount=$(echo $RESULT |jq -r ".data.failCountOfPlan")
    successCase=$(echo $RESULT |jq -r ".data.executeCount.success")
    failedCase=$(echo $RESULT |jq -r ".data.executeCount.error")
    falseFailedCase=$(echo $RESULT |jq -r ".data.executeCount.fakeError")
    blockedCase=$(echo $RESULT |jq -r ".data.executeCount.block")
    notRanCase=$(echo $RESULT |jq -r ".data.executeCount.pending")
	
    ### Now Retrieve the API Case Details
    apiCaseSuccessedCase=$(echo $RESULT |jq -r ".data.apiCaseCount.success")
    apiCaseFailedCase=$(echo $RESULT |jq -r ".data.apiCaseCount.error")
    apiCaseFalseFailedCase=$(echo $RESULT |jq -r ".data.apiCaseCount.fakeError")
    apiCaseBlockedCase=$(echo $RESULT |jq -r ".data.apiCaseCount.block")
    apiCaseNotRanCase=$(echo $RESULT |jq -r ".data.apiCaseCount.pending")
    
    ### Now Retrieve the API Scenario Details
    apiScenarioSuccessedCase=$(echo $RESULT |jq -r ".data.apiScenarioCount.success")
    apiScenarioFailedCase=$(echo $RESULT |jq -r ".data.apiScenarioCount.error")
    apiScenarioFalseFailedCase=$(echo $RESULT |jq -r ".data.apiScenarioCount.fakeError")
    apiScenarioBlockedCase=$(echo $RESULT |jq -r ".data.apiScenarioCount.block")
    apiScenarioNotRanCase=$(echo $RESULT |jq -r ".data.apiScenarioCount.pending")
	
    echo "    "
    echo " #################################################################"
    echo " ##############    The SUMMARY of the REPORT  ####################"
    echo " ###### Report Name \"${ReportName}\" #########"
    echo " #########        Report ID ${reportId}        ##############"
    echo " Overall Result of the Report(执行结果): $STATUS "
    echo " Tocal Case Number (用例总数): $caseTotal "
    echo " Passed Case Number (通过用例数): $successCase "
    echo " Execution Rate (执行完成率): ${executeRate}% "
    echo " Pass Rate (通过率): ${passRate}% "
    echo " Pass Threshold（通过阈值）: ${passThreshold}%"
    echo "   "
    echo " Number of Plans(计划总数): $planCount"
    echo " Number of Passed Plans(成功的计划数): ${passPlanCount:-0}"
    echo " Number of Failed Plans(失败的计划数): ${failedPlanCount:-0}"
    echo "   "
    echo " Number of Success Cases(成功用例数): $successCase"
    echo " Number of Failed Cases(失败用例数): $failedCase"
    echo " Number of falsedFailedCases(误报用例数): $falseFailedCase"
    echo " Number of Blocked Cases(阻塞用例数): $blockedCase"
    echo " Number of notRanCase Cases(未执行用例数): $notRanCase"
    	
    echo "   "
    echo " The Details of the API Cases:"
    echo " Total Number of API Cases(单接口用例总数): ${apiCaseTotal:-0}"
    echo " Number of Success API Cases(成功的单接口用例数): ${apiCaseSuccessedCase:-0}"
    echo " Number of Failed API Cases(失败的单接口用例数): ${apiCaseFailedCase:-0}"
    echo " Number of falseFailed API Cases(误报的单接口用例数): ${apiCaseFalseFailedCase:-0}"
    echo " Number of Blocked API Cases(阻塞的单接口用例数): ${apiCaseBlockedCase:-0}"
    echo " Number of notRanCase API Cases(未执行的单接口用例数): ${apiCaseNotRanCase:-0}"
    	
    echo "   "
    echo " The Details of the API Scenarios:"
    echo " Total Number of API Scenarios(场景总数): ${apiScenarioTotal:-0}"
    echo " Number of Success Scenario Cases(成功的场景用例数): ${apiScenarioSuccessedCase:-0}"
    echo " Number of Failed Scenario Cases(失败的场景用例数): ${apiScenarioFailedCase:-0}"
    echo " Number of falseFailed Scenario Cases(误报的场景用例数): ${apiScenarioFalseFailedCase:-0}"
    echo " Number of Blocked Scenario Cases(阻塞的场景用例数): ${apiScenarioBlockedCase:-0}"
    echo " Number of notRanCase Scenario Cases(未执行的场景用例数): ${apiScenarioNotRanCase:-0}"
    
    echo " #################################################################"
    echo "    " 
    
}

getShareURL()
{

 BODY='{"projectId":"'$projectId'","reportId":"'$reportId'"}'
 ShareUrl=$(curl -k -XPOST -s -H "accesskey: ${accessKey}" -H "signature: ${signature}" -H "Content-Type: application/json" ${HOST_URL}/test-plan/report/share/gen -d "${BODY}" |jq -r ".data.shareUrl")
 reportShareUrl="${HOST_URL}/#/share/shareReportTestPlan${ShareUrl}&type=GROUP"
 echo "        "
 echo " #########################################################"
 echo " Please visit following URL for report details: "
 echo " ${reportShareUrl}"
 echo " #########################################################"
 echo "   "
}

getProjectId
echo " Project Id is: $projectId"
if [ ${projectId}x == ""x ];then
 echo  " Did not return Project Id. Please check the environment and re-run the job"
 exit 1;
fi

getPlanGroupId 
echo " Testplan Group Id is: $planGroupId"
if [ ${planGroupId}x == ""x ];then
 echo  " Did not return testPlanGroup Id. Please check the environment and re-run the job"
 exit 1;
fi


echo " Now Kick off the Plan Group..."
runPlanGroup 

getReportDetails
getShareURL
