-- ==========================================================
--        SCRIPT AUTO-FARM "TÀNG HÌNH" (PHIÊN BẢN ỔN ĐỊNH CUỐI CÙNG)
--        Author: Darcy & Gemini
--        Last Updated: 17/10/2025
-- ==========================================================

-- //////////////// KIỂM TRA VÀ DỪNG SCRIPT CŨ ////////////////
if _G.DarcyFarmIsRunning then print("🔴 Dừng script cũ..."); _G.DarcyFarmIsRunning = false; wait(1) end
_G.DarcyFarmIsRunning = true
-------------------------------------------------------------

-- //////////////// KHỞI TẠO TRẠNG THÁI VÀ CÁC HÀM ////////////////
local farmState = { LobbyAction = "NeedsToCreate", InMatch = false }
local function waitgameisloaded() print("⏳ Chờ game tải..."); if not game:IsLoaded() then game.Loaded:Wait() end; wait(3); print("✅ Game đã tải!") end
local LOBBY_PLACE_ID = 16146832113; local MATCH_PLACE_ID = 16277809958
print("🟢 Script 'Tàng Hình' đã kích hoạt!"); waitgameisloaded()

-- ##################################################################
-- #                     VÒNG LẶP CHÍNH CỦA SCRIPT                  #
-- ##################################################################
while _G.DarcyFarmIsRunning do
    local currentPlaceId = game.PlaceId
    if currentPlaceId == LOBBY_PLACE_ID then
        farmState.InMatch = false
        if farmState.LobbyAction == "NeedsToCreate" then
            farmState.LobbyAction = "WaitingForTeleport"; print("🏠 Đang ở Lobby. Tạo trận..."); wait(2)
            pcall(function()
                local lobbyEvent = game:GetService("ReplicatedStorage").Networking.LobbyEvent
                local addMatchArgs = { [1] = "AddMatch", [2] = { ["Difficulty"] = "Normal", ["Act"] = "Act1", ["StageType"] = "Story", ["Stage"] = "Stage1", ["FriendsOnly"] = false } }
                lobbyEvent:FireServer(unpack(addMatchArgs)); print("➕ Đã tạo trận.")
                wait(3)
                lobbyEvent:FireServer("StartMatch"); print("🚀 Đã bắt đầu trận!")
            end)
        end
    elseif currentPlaceId == MATCH_PLACE_ID and not farmState.InMatch then
        farmState.InMatch = true
        print("⚔️ Đã vào trận. Bắt đầu VÒNG LẶP FARM NỘI BỘ.")
        print("⏳ Chờ 20 giây để game ổn định...")
        wait(20)
        
        while currentPlaceId == MATCH_PLACE_ID and _G.DarcyFarmIsRunning do
            print("-----------------------------------"); print("🔥 Bắt đầu lượt chơi mới...")
            
            spawn(function()
                pcall(function()
                    local skipWaveGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("SkipWave", 45)
                    if skipWaveGui and skipWaveGui.Parent and skipWaveGui:FindFirstChild("Holder") and skipWaveGui.Holder:FindFirstChild("Yes") then
                       game:GetService("ReplicatedStorage").Networking.SkipWaveEvent:FireServer("Skip")
                    end
                end)
            end)
            
            print("⏳ Chờ 3 giây sau khi vote Yes...")
            wait(3)

            -- ====================================================================================
            --        <<< BẮT ĐẦU KHỐI LOGIC ĐẶT & NÂNG CẤP UNIT BẠN CUNG CẤP >>>
            -- ====================================================================================
            do
                local unitState = { isRokuPlaced = false, isAckerPlaced = false, ackerUpgradeLevel = 0 }
                local ROKU_COST = 400; local ACKER_COST = 1000
                local ACKER_UPGRADES = { [1] = 2400, [2] = 3600, [3] = 5200 }
                local ROKU_POSITION = Vector3.new(431.536, 4.840, -358.474)
                local ACKER_POSITION = Vector3.new(445.913, 3.529, -345.790)
                local ACKER_INSTANCE_ID = "285ec435-1558-4919-ad60-ec7a6449ba86"
                local UnitEvent = game:GetService("ReplicatedStorage").Networking.UnitEvent
                local function getCurrentMoney() local moneyAmount = 0; pcall(function() local moneyLabel = game:GetService("Players").LocalPlayer.PlayerGui.Hotbar.Main.Yen; local numberString = string.gsub(moneyLabel.Text, "[^%d]", ""); moneyAmount = tonumber(numberString) or 0 end); return moneyAmount end
                local function placeUnit(unitName, unitId, position) pcall(function() UnitEvent:FireServer("Render", {unitName, unitId, position, 0}); print(string.format("✅ Đã gửi yêu cầu đặt: %s", unitName)) end) end
                local function upgradeAcker() pcall(function() UnitEvent:FireServer("Upgrade", ACKER_INSTANCE_ID); print("🚀 Đã gửi yêu cầu nâng cấp Acker!") end) end
                
                while unitState.ackerUpgradeLevel < 3 and _G.DarcyFarmIsRunning do
                    local currentMoney = getCurrentMoney()
                    if not unitState.isRokuPlaced and currentMoney >= ROKU_COST then
                        print(string.format("💰 Đủ tiền (%d/%d). Đang đặt Roku...", currentMoney, ROKU_COST))
                        placeUnit("Roku", 41, ROKU_POSITION); unitState.isRokuPlaced = true
                    elseif unitState.isRokuPlaced and not unitState.isAckerPlaced and currentMoney >= ACKER_COST then
                        print(string.format("💰 Đủ tiền (%d/%d). Đang đặt Acker...", currentMoney, ACKER_COST))
                        placeUnit("Ackers", 241, ACKER_POSITION); unitState.isAckerPlaced = true
                    elseif unitState.isAckerPlaced and unitState.ackerUpgradeLevel < 3 then
                        local nextUpgradeLevel = unitState.ackerUpgradeLevel + 1
                        local upgradeCost = ACKER_UPGRADES[nextUpgradeLevel]
                        if currentMoney >= upgradeCost then
                            print(string.format("💰 Đủ tiền (%d/%d). Đang nâng cấp Acker lên level %d...", currentMoney, upgradeCost, nextUpgradeLevel))
                            upgradeAcker(); unitState.ackerUpgradeLevel = nextUpgradeLevel
                        end
                    end
                    wait(0.5)
                end
                
                if not _G.DarcyFarmIsRunning then
                    print("⏹️ Script đã dừng theo lệnh trong lúc farm.")
                else
                    print("✅ Hoàn thành quy trình đặt và nâng cấp unit.")
                end
            end
            -- ====================================================================================
            --        <<< KẾT THÚC KHỐI LOGIC BẠN CUNG CẤP >>>
            -- ====================================================================================
            
            -- >> LOGIC CHỜ ENDSCREEN VÀ RETRY VÀO ĐÂY <<
            -- ...
            
            break -- Thoát khỏi vòng lặp trong trận để bắt đầu lại từ đầu
        end
        print("🚪 Đã thoát khỏi vòng lặp farm nội bộ."); farmState.LobbyAction = "NeedsToCreate"
    end
    wait(2)
end
print("⏹️ Script đã dừng hẳn theo lệnh.")
