---------------------------------------------------------------------------------------------
-- Requirement summary: 
--     [RegisterAppInterface] DISALLOWED app`s nickname does not match ones listed in Policy Table
--
-- Description: 
--     SDL should disallow app registration in case app`s nickname 
--     does not match those listed in Policy Table under the appID this app registers with.
--
-- Preconditions:
--     1. Local PT contains <appID> section (for example, appID="123_xyz") in "app_policies"
--        with nickname = "Media Application"
--     2. appID="123_xyz" is not registered to SDL yet
--     3. SDL.OnStatusUpdate = "UP_TO_DATE"
-- Steps:
--     1. Register new application with appID="123_xyz" and nickname = "ABCD"
--     2. Verify status of registeration
--
-- Expected result:
--     SDL must respond with the following data: success = false, resultCode = "DISALLOWED"
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
  config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
  local mobileSession = require("mobile_session")
  local common = require("user_modules/shared_testcases/testCasesForPolicyAppIdManagament")  
  local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
  local commonSteps = require("user_modules/shared_testcases/commonSteps")  

--[[ General Precondition before ATF start ]]  
  commonFunctions:SDLForceStop()  
  commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
  Test = require("connecttest") 
  require("user_modules/AppTypes")

--[[ Preconditions ]]
  commonFunctions:newTestCasesGroup("Preconditions")
  function Test:UpdatePolicy()
    common:updatePolicyTable(self, "files/jsons/Policies/appID_Management/ptu_0.json")
  end

  function Test:StartNewSession()
    self.mobileSession2 = mobileSession.MobileSession(self, self.mobileConnection)
    self.mobileSession2:StartService(7)
  end  

--[[ Test ]]  
  commonFunctions:newTestCasesGroup("Test")
  function Test:RegisterNewApp()  
    config.application2.registerAppInterfaceParams.appName = "ABCD"
    config.application2.registerAppInterfaceParams.appID = "123_xyz"
    local corId = self.mobileSession2:SendRPC("RegisterAppInterface", config.application2.registerAppInterfaceParams)
    self.mobileSession2:ExpectResponse(corId, { success = false, resultCode = "DISALLOWED" })    
  end


return Test	