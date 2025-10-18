-- ==========================================================
--        SCRIPT AUTO-FARM "Tàng Hình" (FINAL - CHUẨN SETTING CHECK)
--        Author: Darcy & Gemini
--        Last Updated: 18/10/2025
-- ==========================================================

-- //////////////// KIỂM TRA VÀ DỪNG SCRIPT CŨ ////////////////
if _G.DarcyFarmIsRunning then print("🔴 Dừng script cũ..."); _G.DarcyFarmIsRunning = false; wait(1) end
_G.DarcyFarmIsRunning = true
-------------------------------------------------------------

-- //////////////// KHỞI TẠO TRẠNG THÁI VÀ CÁC HÀM ////////////////
-- Trạng thái Lobby: NeedsCheck, Rejoining, NeedsPostRejoinSetup, NeedsMatchStart, WaitingForTeleport
local farmState = { LobbyAction = "NeedsCheck", InMatch = false }
local function waitgameisloaded() print("⏳ Chờ game tải..."); if not game:IsLoaded() then game.Loaded:Wait() end; wait(3); print("✅ Game đã tải!") end
local function claimNewPlayerReward() print("🔎 Kiểm tra phần thưởng..."); pcall(function() local dayIndicatorPath=game:GetService("Players").LocalPlayer.PlayerGui.NewPlayers.Holder.TopRewards.SmallTemplate.SmallTemplate.Main.Day; if dayIndicatorPath then print("🎁 Nhận thưởng ngày 1..."); local remote=game:GetService("ReplicatedStorage").Networking.NewPlayerRewardsEvent; remote:FireServer("Claim", 1); print("✅ Đã nhận.") end end) end
local function selectStartingUnit_Roku() print("📌 Chọn unit 'Roku'..."); pcall(function() local remote=game:GetService("ReplicatedStorage").Networking.Units.UnitSelectionEvent; remote:FireServer("Select", "Roku"); print("✅ Đã chọn.") end) end
local function getEquipIdByName(unitDisplayName) print("   🔎 Tìm ID:", unitDisplayName); local equipId=nil; local s,e=pcall(function() local f=game:GetService("Players").LocalPlayer.PlayerGui.Windows.Units.Holder.Main.Units; for _,u in ipairs(f:GetChildren()) do if u:IsA("Frame") and string.match(u.Name,"^%x%x%x%x%x%x%x%x%-%x%x%x%x%-") then local l=u:FindFirstChild("Holder",true) and u.Holder:FindFirstChild("Main",true) and u.Holder.Main:FindFirstChild("UnitName",true); if l and l:IsA("TextLabel") then local n=string.match(l.Text,"^[^(]+"); if n and string.lower(string.gsub(n,"%s+$",""))==string.lower(unitDisplayName) then equipId=u.Name; print("      ✅ ID:",equipId); break end end end end end); if not s then warn("Lỗi quét GUI:",e) elseif not equipId then warn("⚠️ Không thấy ID.") end; return equipId end
local function checkAndEquipUnits() print("🛡️ Trang bị units..."); local s,e=pcall(function() local E=game:GetService("ReplicatedStorage").Networking.Units.EquipEvent; local rID=getEquipIdByName("Roku"); local aID=getEquipIdByName("Ackers"); if rID then local args={[1]="Equip",[2]=rID}; E:FireServer(unpack(args)); print("⬆️ Gửi equip Roku."); wait(2) else print("❌ Không thấy ID Roku.") end; if aID then local args={[1]="Equip",[2]=aID}; E:FireServer(unpack(args)); print("⬆️ Gửi equip Acker."); wait(1) else print("❌ Không thấy ID Acker.") end; print("✅ Xong trang bị.") end); if not s then warn("⚠️ Lỗi trang bị:",e) end end
local function handleDialogues() print("🔎 Kiểm tra hội thoại..."); local playerGui=game:GetService("Players").LocalPlayer.PlayerGui; local DialogueEvent=game:GetService("ReplicatedStorage").Networking.State.DialogueEvent; local dialogueFound=false; local okayButton=playerGui:FindFirstChild("Dialogue",true) and playerGui.Dialogue:FindFirstChild("Dialogue",true) and playerGui.Dialogue.Dialogue:FindFirstChild("Options",true) and playerGui.Dialogue.Dialogue.Options:FindFirstChild("Option1",true) and playerGui.Dialogue.Dialogue.Options.Option1:FindFirstChild("Okay!"); if okayButton and okayButton.Parent then dialogueFound=true; print("✅ Xử lý 'Okay!'..."); pcall(function() DialogueEvent:FireServer("Interact", {"StarterUnitDialogue", 1, "Okay!"}) end); wait(8) end; local yeahButton=playerGui:FindFirstChild("Dialogue",true) and playerGui.Dialogue:FindFirstChild("Dialogue",true) and playerGui.Dialogue.Dialogue:FindFirstChild("Options",true) and playerGui.Dialogue.Dialogue.Options:FindFirstChild("Option1",true) and playerGui.Dialogue.Dialogue.Options.Option1:FindFirstChild("Yeah!"); if yeahButton and yeahButton.Parent then dialogueFound=true; print("✅ Xử lý 'Yeah!'..."); pcall(function() DialogueEvent:FireServer("Interact", {"StarterUnitDialogue", 2, "Yes!"}) end); wait(1) else if okayButton and okayButton.Parent then warn("⚠️ Không thấy hội thoại 'Yeah!'.") end end; return dialogueFound end
local function rejoinCurrentServer() print("🔄 Rejoining server..."); pcall(function() local TS=game:GetService("TeleportService"); local Plrs=game:GetService("Players"); TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, Plrs.LocalPlayer) end) end

-- <<< HÀM BẬT SETTING (CHECK MÀU UIGRADIENT) >>>
local function enableAllSettings()
    print("-----------------------------------"); print("⚙️ Kiểm tra cài đặt...")
    local success, err = pcall(function()
        -- >> NHỚ CẬP NHẬT ĐƯỜNG DẪN NÀY << --
        local gameplayFolder = game:GetService("Players").LocalPlayer.PlayerGui.Windows.Settings.Holder.Main.ScrollingFrame.Gameplay

        local settingsToEnable = {
            ["Auto Skip Waves"] = "AutoSkipWaves", ["Select Unit on Placement"] = "SelectUnitOnPlacement",
            ["Show Multipliers on Hover"] = "ShowMultipliersOnHover", ["Disable Match End Rewards View"] = "DisableMatchEndRewardsView",
            ["Show Max Range on Placement"] = "ShowMaxRangeOnPlacement", ["Low Detail Mode"] = "LowDetailMode",
            ["Disable Camera Shake"] = "DisableCameraShake", ["Disable Depth of Field"] = "DisableDepthOfField",
            ["Hide Familiars"] = "HideFamiliars"
        }
        local SettingsEvent = game:GetService("ReplicatedStorage").Networking.Settings.SettingsEvent

        for settingFrameName, remoteName in pairs(settingsToEnable) do
            local settingFrame = gameplayFolder:FindFirstChild(settingFrameName)
            if settingFrame then
                -- Tìm UIGradient theo đường dẫn bạn cung cấp
                local uiGradient = settingFrame:FindFirstChild("Slider", true) and settingFrame.Slider:FindFirstChild("Ball", true) and settingFrame.Slider.Ball:FindFirstChild("UIGradient")
                
                if uiGradient and uiGradient:IsA("UIGradient") then
                    local currentSequence = uiGradient.Color
                    if #currentSequence.Keypoints > 0 then
                        local firstColor = currentSequence.Keypoints[1].Value
                        -- Kiểm tra màu: Xanh (Bật) khi G > R và G > 0.5
                        if not (firstColor.G > firstColor.R and firstColor.G > 0.5) then
                            print("❌ '"..settingFrameName.."' đang TẮT. Bật...")
                            SettingsEvent:FireServer("Toggle", remoteName)
                        else
                            print("✅ '"..settingFrameName.."' đã BẬT.")
                        end
                    else warn("⚠️ UIGradient của '"..settingFrameName.."' không có keypoints.") end
                else warn("⚠️ Không tìm thấy UIGradient cho '"..settingFrameName.."' theo đường dẫn.") end
            else warn("⚠️ Không thấy Frame cài đặt: '" .. settingFrameName .. "'") end
            wait(0.2)
        end
    end); if not success then warn("‼️ Lỗi bật cài đặt:", err) end; print("⚙️ Xong kiểm tra cài đặt.")
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
        if farmState.LobbyAction == "NeedsCheck" then
            farmState.LobbyAction = "WaitingForTeleport"; print("🏠 Đang ở Lobby...")
            local isNewPlayer = handleDialogues()
            if isNewPlayer then
                print("✨ Luồng người chơi mới..."); selectStartingUnit_Roku(); farmState.LobbyAction = "Rejoining"; wait(2); rejoinCurrentServer(); wait(15)
            else
                print("🔄 Người chơi cũ/sau rejoin."); farmState.LobbyAction = "NeedsPostRejoinSetup"
            end
        elseif farmState.LobbyAction == "NeedsPostRejoinSetup" then
            print("🔧 Setup sau rejoin..."); claimNewPlayerReward(); wait(5); checkAndEquipUnits(); wait(5); farmState.LobbyAction = "NeedsMatchStart"
        elseif farmState.LobbyAction == "NeedsMatchStart" then
            print("➡️ Tạo trận..."); pcall(function() local lobbyEvent = game:GetService("ReplicatedStorage").Networking.LobbyEvent; local addMatchArgs = { [1] = "AddMatch", [2] = { ["Difficulty"] = "Normal", ["Act"] = "Act1", ["StageType"] = "Story", ["Stage"] = "Stage1", ["FriendsOnly"] = false } }; lobbyEvent:FireServer(unpack(addMatchArgs)); print("➕ Đã tạo trận."); wait(3); lobbyEvent:FireServer("StartMatch"); print("🚀 Đã bắt đầu trận!") end); farmState.LobbyAction = "WaitingForTeleport"
        elseif farmState.LobbyAction == "WaitingForTeleport" then print("⏳ Chờ dịch chuyển...")
        elseif farmState.LobbyAction == "Rejoining" then print("⏳ Rejoining..."); wait(5) end
    elseif currentPlaceId == MATCH_PLACE_ID then
        if not farmState.InMatch then
             farmState.InMatch = true; print("⚔️ Đã vào trận. Bắt đầu VÒNG LẶP FARM VÔ HẠN.")
             enableAllSettings() -- Gọi hàm bật setting ở đây
             local hasCompletedFirstRun = false
             print("⏳ Chờ 20 giây..."); wait(20)
        end
        while currentPlaceId == MATCH_PLACE_ID and _G.DarcyFarmIsRunning do
            print("-----------------------------------"); print("🔥 Bắt đầu lượt chơi mới...")
            spawn(function() pcall(function() local skipWaveGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("SkipWave", 45); if skipWaveGui and skipWaveGui.Parent and skipWaveGui:FindFirstChild("Holder") and skipWaveGui.Holder:FindFirstChild("Yes") then game:GetService("ReplicatedStorage").Networking.SkipWaveEvent:FireServer("Skip") end end) end)
            print("⏳ Chờ 3 giây..."); wait(3)
            do -- Khối logic đặt và nâng cấp unit
                local unitState = { isRokuPlaced = false, isAckerPlaced = false, ackerUpgradeLevel = 0 }; local ACKER_INSTANCE = nil; local ROKU_COST = 400; local ACKER_COST = 1000; local ACKER_UPGRADES = { [1] = 2400, [2] = 3600, [3] = 5200 }; local ROKU_POSITION = Vector3.new(431.536, 4.840, -358.474); local ACKER_POSITION = Vector3.new(445.913, 3.529, -345.790); local UnitEvent = game:GetService("ReplicatedStorage").Networking.UnitEvent
                local function getCurrentMoney() local moneyAmount=0; pcall(function() local lbl=game:GetService("Players").LocalPlayer.PlayerGui.Hotbar.Main.Yen; local str=string.gsub(lbl.Text,"[^%d]",""); moneyAmount=tonumber(str) or 0 end); return moneyAmount end
                local function getUnitInstanceAtPosition(position) local unitsFolder = workspace:FindFirstChild("Units"); if not unitsFolder then return nil end; for _, unit in ipairs(unitsFolder:GetChildren()) do local unitRoot = unit:FindFirstChild("HumanoidRootPart") or unit.PrimaryPart; if unitRoot and (unitRoot.Position - position).Magnitude < 1 then print("✅ 'Săn' ID Acker: "..unit.Name); return unit end end; return nil end
                while unitState.ackerUpgradeLevel < 3 and _G.DarcyFarmIsRunning and currentPlaceId == MATCH_PLACE_ID do
                    local currentMoney = getCurrentMoney()
                    if not unitState.isRokuPlaced and currentMoney >= ROKU_COST then print(string.format("💰 (%d/%d) Đặt Roku...", currentMoney, ROKU_COST)); UnitEvent:FireServer("Render", {"Roku", 41, ROKU_POSITION, 0}); unitState.isRokuPlaced = true
                    elseif unitState.isRokuPlaced and not unitState.isAckerPlaced and currentMoney >= ACKER_COST then print(string.format("💰 (%d/%d) Đặt Acker...", currentMoney, ACKER_COST)); UnitEvent:FireServer("Render", {"Ackers", 241, ACKER_POSITION, 0}); unitState.isAckerPlaced = true; wait(1.5); ACKER_INSTANCE = getUnitInstanceAtPosition(ACKER_POSITION)
                    elseif ACKER_INSTANCE and unitState.ackerUpgradeLevel < 3 then
                        local nextUpgradeLevel = unitState.ackerUpgradeLevel + 1; local upgradeCost = ACKER_UPGRADES[nextUpgradeLevel]
                        if currentMoney >= upgradeCost then print(string.format("💰 (%d/%d) Nâng cấp Acker #%d...", currentMoney, upgradeCost, nextUpgradeLevel)); UnitEvent:FireServer("Upgrade", ACKER_INSTANCE.Name); unitState.ackerUpgradeLevel = nextUpgradeLevel end
                    end; wait(0.5); currentPlaceId = game.PlaceId
                end; print("✅ Xong đặt/nâng cấp.")
            end
            if not hasCompletedFirstRun then print("⏳ (Lượt đầu) Chờ RewardsDisplay..."); local rewardsDisplay = game.Players.LocalPlayer.PlayerGui:WaitForChild("RewardsDisplay", 1200); if rewardsDisplay and rewardsDisplay.Parent and _G.DarcyFarmIsRunning then print("🏆 Gửi Retry..."); wait(1); pcall(function() game:GetService("ReplicatedStorage").Networking.EndScreen.VoteEvent:FireServer("Retry"); print("🔄 Đã Retry!") end); hasCompletedFirstRun = true; wait(5) else print("❌ Không thấy màn hình thưởng."); break end
            else print("⏳ (Lượt sau) Chờ EndScreen..."); local endScreenGui; while _G.DarcyFarmIsRunning and not (endScreenGui and endScreenGui.Parent) do endScreenGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("EndScreen"); wait(0.5) end; if _G.DarcyFarmIsRunning and endScreenGui then local holder = endScreenGui:FindFirstChild("Holder"); if holder and holder:FindFirstChild("Buttons") and holder.Buttons:FindFirstChild("Retry") then print("✅ Thấy nút Retry! Gửi Retry..."); wait(3); pcall(function() game:GetService("ReplicatedStorage").Networking.EndScreen.VoteEvent:FireServer("Retry"); print("🔄 Đã Retry!") end); wait(5) else print("❌ Không thấy nút Retry."); break end else print("❌ Không thấy EndScreen."); break end end
            currentPlaceId = game.PlaceId
        end
        print("🚪 Thoát vòng lặp farm nội bộ."); farmState.LobbyAction = "NeedsCheck"
    end
    wait(2)
end
print("⏹️ Script đã dừng hẳn theo lệnh.")
