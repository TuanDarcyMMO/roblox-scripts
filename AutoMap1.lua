-- ==========================================================
--        SCRIPT AUTO-FARM "TÀNG HÌNH" (PHIÊN BẢN ỔN ĐỊNH)
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
        
        -- <<< THÊM ĐỘ TRỄ AN TOÀN 10 GIÂY Ở ĐÂY >>>
        print("⏳ Chờ 10 giây để đảm bảo tất cả GUI và assets của game đã tải xong...")
        wait(10)
        
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
            
            -- <<< THÊM ĐỘ TRỄ 3 GIÂY SAU KHI KÍCH HOẠT 'CANH GÁC' >>>
            print("⏳ Chờ 3 giây sau khi vote Yes...")
            wait(3)

            -- Bắt đầu logic đặt và nâng cấp unit
            print("🔄 Bắt đầu logic chính: Đặt và nâng cấp unit...")
            local unitState = { isRokuPlaced = false, isAckerPlaced = false, ackerUpgradeLevel = 0 }
            local ROKU_COST, ACKER_COST = 400, 1000; local ACKER_UPGRADES = { [1] = 2400, [2] = 3600, [3] = 5200 }
            local ROKU_POS, ACKER_POS = Vector3.new(431.536, 4.840, -358.474), Vector3.new(445.913, 3.529, -345.790)
            local ACKER_INSTANCE_ID = "285ec435-1558-4919-ad60-ec7a6449ba86"
            local UnitEvent = game:GetService("ReplicatedStorage").Networking.UnitEvent
            local function getCurrentMoney() local money = 0; pcall(function() money = tonumber(string.gsub(game.Players.LocalPlayer.PlayerGui.Hotbar.Main.Yen.Text, "[^%d]", "")) or 0 end); return money end
            
            while unitState.ackerUpgradeLevel < 3 and currentPlaceId == MATCH_PLACE_ID and _G.DarcyFarmIsRunning do
                local currentMoney = getCurrentMoney()
                if not unitState.isRokuPlaced and currentMoney >= ROKU_COST then
                    print(string.format("💰 Đủ tiền (%d/%d). Đặt Roku...", currentMoney, ROKU_COST))
                    UnitEvent:FireServer("Render", {"Roku", 41, ROKU_POS, 0}); unitState.isRokuPlaced = true; wait(1)
                elseif not unitState.isAckerPlaced and currentMoney >= ACKER_COST then
                    print(string.format("💰 Đủ tiền (%d/%d). Đặt Acker...", currentMoney, ACKER_COST))
                    UnitEvent:FireServer("Render", {"Ackers", 241, ACKER_POS, 0}); unitState.isAckerPlaced = true; wait(1)
                elseif unitState.isAckerPlaced and unitState.ackerUpgradeLevel < 3 then
                    local nextLvl = unitState.ackerUpgradeLevel + 1; local cost = ACKER_UPGRADES[nextLvl]
                    if currentMoney >= cost then
                        print(string.format("💰 Đủ tiền (%d/%d). Nâng cấp Acker lên #%d...", currentMoney, cost, nextLvl))
                        UnitEvent:FireServer("Upgrade", ACKER_INSTANCE_ID); unitState.ackerUpgradeLevel = nextLvl; wait(1)
                    end
                end
                wait(0.5); currentPlaceId = game.PlaceId
            end
            print("✅ Hoàn thành quy trình đặt và nâng cấp unit cho lượt này!")

            -- >> LOGIC CHỜ ENDSCREEN VÀ RETRY VÀO ĐÂY <<
            -- ...
            
            break -- Thoát khỏi vòng lặp trong trận để bắt đầu lại từ đầu
        end
        print("🚪 Đã thoát khỏi vòng lặp farm nội bộ."); farmState.LobbyAction = "NeedsToCreate"
    end
    wait(2)
end
print("⏹️ Script đã dừng hẳn theo lệnh.")
