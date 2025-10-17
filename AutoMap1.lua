-- ==========================================================
--        SCRIPT AUTO-FARM "TÀNG HÌNH" (PHIÊN BẢN HOÀN THIỆN NHẤT)
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

-- <<< HÀM TỰ ĐỘNG KIỂM TRA VÀ BẬT CÀI ĐẶT >>>
local function enableAllSettings()
    print("-----------------------------------")
    print("⚙️ Bắt đầu kiểm tra và kích hoạt cài đặt...")
    local success, err = pcall(function()
        -- >> BẠN CẦN DÙNG DEX EXPLORER ĐỂ TÌM ĐƯỜNG DẪN CHÍNH XÁC ĐẾN THƯ MỤC NÀY << --
        local settingsFolder = game:GetService("Players").LocalPlayer.PlayerGui.Settings.Holder.Gameplay
        
        local settingsToEnable = {
            ["Auto Skip Waves"] = "AutoSkipWaves", ["Select Unit on Placement"] = "SelectUnitOnPlacement",
            ["Show Multipliers on Hover"] = "ShowMultipliersOnHover", ["Disable Match End Rewards View"] = "DisableMatchEndRewardsView",
            ["Show Max Range on Placement"] = "ShowMaxRangeOnPlacement", ["Low Detail Mode"] = "LowDetailMode",
            ["Disable Camera Shake"] = "DisableCameraShake", ["Disable Depth of Field"] = "DisableDepthOfField",
            ["Hide Familiars"] = "HideFamiliars"
        }
        local SettingsEvent = game:GetService("ReplicatedStorage").Networking.Settings.SettingsEvent
        for guiName, remoteName in pairs(settingsToEnable) do
            local mainButton = settingsFolder:FindFirstChild(guiName)
            if mainButton then
                if mainButton.GuiState ~= Enum.GuiState.Idle then
                    print("❌ Cài đặt '" .. guiName .. "' đang TẮT. Đang bật...")
                    SettingsEvent:FireServer("Toggle", remoteName)
                else
                    print("✅ Cài đặt '" .. guiName .. "' đã BẬT.")
                end
            else
                warn("⚠️ Không tìm thấy nút cài đặt: '" .. guiName .. "'")
            end
            wait(0.2)
        end
    end)
    if not success then warn("‼️ Lỗi khi bật cài đặt. Có thể đường dẫn đến Settings GUI đã thay đổi. Lỗi:", err) end
    print("⚙️ Hoàn thành kiểm tra cài đặt.")
end

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
            pcall(function() local lobbyEvent = game:GetService("ReplicatedStorage").Networking.LobbyEvent; local addMatchArgs = { [1] = "AddMatch", [2] = { ["Difficulty"] = "Normal", ["Act"] = "Act1", ["StageType"] = "Story", ["Stage"] = "Stage1", ["FriendsOnly"] = false } }; lobbyEvent:FireServer(unpack(addMatchArgs)); print("➕ Đã tạo trận."); wait(3); lobbyEvent:FireServer("StartMatch"); print("🚀 Đã bắt đầu trận!") end)
        end
    elseif currentPlaceId == MATCH_PLACE_ID and not farmState.InMatch then
        farmState.InMatch = true
        print("⚔️ Đã vào trận. Bắt đầu VÒNG LẶP FARM VÔ HẠN.")
        
        -- GỌI HÀM BẬT CÀI ĐẶT (CHỈ 1 LẦN KHI VÀO TRẬN)
        enableAllSettings()
        
        print("⏳ Chờ 20 giây để game ổn định...")
        wait(20)
        
        while currentPlaceId == MATCH_PLACE_ID and _G.DarcyFarmIsRunning do
            print("-----------------------------------"); print("🔥 Bắt đầu lượt chơi mới...")
            spawn(function() pcall(function() local skipWaveGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("SkipWave", 45); if skipWaveGui and skipWaveGui.Parent and skipWaveGui:FindFirstChild("Holder") and skipWaveGui.Holder:FindFirstChild("Yes") then game:GetService("ReplicatedStorage").Networking.SkipWaveEvent:FireServer("Skip") end end) end)
            print("⏳ Chờ 3 giây cho wave bắt đầu..."); wait(3)

            do -- Khối logic đặt và nâng cấp unit
                local unitState = { isRokuPlaced = false, isAckerPlaced = false, ackerUpgradeLevel = 0 }; local ACKER_INSTANCE = nil; local ROKU_COST = 400; local ACKER_COST = 1000; local ACKER_UPGRADES = { [1] = 2400, [2] = 3600, [3] = 5200 }; local ROKU_POSITION = Vector3.new(431.536, 4.840, -358.474); local ACKER_POSITION = Vector3.new(445.913, 3.529, -345.790); local UnitEvent = game:GetService("ReplicatedStorage").Networking.UnitEvent
                local function getCurrentMoney() local moneyAmount=0; pcall(function() local lbl=game:GetService("Players").LocalPlayer.PlayerGui.Hotbar.Main.Yen; local str=string.gsub(lbl.Text,"[^%d]",""); moneyAmount=tonumber(str) or 0 end); return moneyAmount end
                local function getUnitInstanceAtPosition(position) local unitsFolder = workspace:FindFirstChild("Units"); if not unitsFolder then return nil end; for _, unit in ipairs(unitsFolder:GetChildren()) do local unitRoot = unit:FindFirstChild("HumanoidRootPart") or unit.PrimaryPart; if unitRoot and (unitRoot.Position - position).Magnitude < 1 then print("✅ Đã 'săn' được ID Acker:", unit.Name); return unit end end; return nil end
                while unitState.ackerUpgradeLevel < 3 and _G.DarcyFarmIsRunning and currentPlaceId == MATCH_PLACE_ID do
                    local currentMoney = getCurrentMoney()
                    if not unitState.isRokuPlaced and currentMoney >= ROKU_COST then print(string.format("💰 Đủ tiền (%d/%d). Đặt Roku...", currentMoney, ROKU_COST)); UnitEvent:FireServer("Render", {"Roku", 41, ROKU_POSITION, 0}); unitState.isRokuPlaced = true
                    elseif unitState.isRokuPlaced and not unitState.isAckerPlaced and currentMoney >= ACKER_COST then print(string.format("💰 Đủ tiền (%d/%d). Đặt Acker...", currentMoney, ACKER_COST)); UnitEvent:FireServer("Render", {"Ackers", 241, ACKER_POSITION, 0}); unitState.isAckerPlaced = true; wait(1.5); ACKER_INSTANCE = getUnitInstanceAtPosition(ACKER_POSITION)
                    elseif ACKER_INSTANCE and unitState.ackerUpgradeLevel < 3 then
                        local nextUpgradeLevel = unitState.ackerUpgradeLevel + 1; local upgradeCost = ACKER_UPGRADES[nextUpgradeLevel]
                        if currentMoney >= upgradeCost then print(string.format("💰 Đủ tiền (%d/%d). Nâng cấp Acker (ID: %s)...", currentMoney, upgradeCost, ACKER_INSTANCE.Name)); UnitEvent:FireServer("Upgrade", ACKER_INSTANCE.Name); unitState.ackerUpgradeLevel = nextUpgradeLevel end
                    end
                    wait(0.5); currentPlaceId = game.PlaceId
                end; print("✅ Hoàn thành quy trình đặt và nâng cấp unit.")
            end
            
            print("⏳ Chờ màn hình nhận thưởng (RewardsDisplay) để retry...")
            local rewardsDisplay = game.Players.LocalPlayer.PlayerGui:WaitForChild("RewardsDisplay", 1200)
            if rewardsDisplay and rewardsDisplay.Parent and _G.DarcyFarmIsRunning then
                print("🏆 Phát hiện RewardsDisplay! Gửi lệnh Retry ngay lập tức..."); wait(1)
                pcall(function() game:GetService("ReplicatedStorage").Networking.EndScreen.VoteEvent:FireServer("Retry"); print("🔄 Đã gửi yêu cầu 'Retry'!") end); wait(5)
            else print("❌ Không tìm thấy màn hình thưởng hoặc script đã bị dừng."); break end
        end
        print("🚪 Đã thoát khỏi vòng lặp farm nội bộ."); farmState.LobbyAction = "NeedsToCreate"
    end
    wait(2)
end
print("⏹️ Script đã dừng hẳn theo lệnh.")
