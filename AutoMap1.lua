-- ==========================================================
--        SCRIPT AUTO-FARM (GUI LOG NHẸ)
--        Author: Darcy & Gemini
--        Last Updated: 18/10/2025
-- ==========================================================

-- //////////////// KIỂM TRA VÀ DỪNG SCRIPT CŨ ////////////////
if _G.DarcyFarmControl and typeof(_G.DarcyFarmControl) == "table" then
    _G.DarcyFarmControl.State = "Stopped"
    if _G.DarcyFarmControl.GUI and _G.DarcyFarmControl.GUI.Parent then _G.DarcyFarmControl.GUI:Destroy() end
    wait(0.5)
end
_G.DarcyFarmControl = { State = "Running", MaxLogs = 15 } -- Giảm số log tối đa cho gọn
-------------------------------------------------------------

-- //////////////// KHỞI TẠO GUI LOG ////////////////
local controlGui = Instance.new("ScreenGui")
controlGui.Name = "DarcyFarmLogGUI"
controlGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
_G.DarcyFarmControl.GUI = controlGui

local mainFrame = Instance.new("Frame", controlGui)
mainFrame.Size = UDim2.new(0, 250, 0, 150) -- Kích thước nhỏ gọn hơn
mainFrame.Position = UDim2.new(0, 10, 0.5, -75) -- Đặt ở góc trái giữa màn hình
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
local corner = Instance.new("UICorner", mainFrame); corner.CornerRadius = UDim.new(0, 6)

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 20)
titleLabel.Text = "🚀 Darcy Farm Status"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
titleLabel.BackgroundTransparency = 0.1
titleLabel.Font = Enum.Font.SourceSansSemibold
titleLabel.TextSize = 14
local titleCorner = Instance.new("UICorner", titleLabel); titleCorner.CornerRadius = UDim.new(0, 6)

local logFrame = Instance.new("ScrollingFrame", mainFrame)
logFrame.Size = UDim2.new(1, -10, 1, -25) -- Padding nhỏ
logFrame.Position = UDim2.new(0, 5, 0, 20)
logFrame.BackgroundTransparency = 1
logFrame.BorderSizePixel = 0
logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logFrame.ScrollBarThickness = 3

local logLayout = Instance.new("UIListLayout", logFrame)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Padding = UDim.new(0, 1)
-------------------------------------------------------------

-- //////////////// HÀM IN LOG RA GUI ////////////////
function customLog(message)
    print(message) -- Vẫn in ra F9 để debug
    if not (_G.DarcyFarmControl.GUI and _G.DarcyFarmControl.GUI.Parent) then return end -- Kiểm tra GUI còn tồn tại không
    local newLog = Instance.new("TextLabel", logFrame); newLog.Text = "  " .. message; newLog.TextColor3 = Color3.fromRGB(220, 220, 220); newLog.Font = Enum.Font.SourceSans; newLog.TextSize = 12; newLog.TextXAlignment = Enum.TextXAlignment.Left; newLog.BackgroundTransparency = 1; newLog.Size = UDim2.new(1, 0, 0, 16); newLog.LayoutOrder = -tick()
    if #logFrame:GetChildren() > _G.DarcyFarmControl.MaxLogs + 1 then local oldestLog; local maxLayoutOrder = -math.huge; for _, child in pairs(logFrame:GetChildren()) do if child:IsA("TextLabel") and child.LayoutOrder > maxLayoutOrder then maxLayoutOrder = child.LayoutOrder; oldestLog = child end end; if oldestLog then oldestLog:Destroy() end end
    logFrame.CanvasPosition = Vector2.new(0,0) -- Tự cuộn lên đầu
end
-------------------------------------------------------------

-- //////////////// KHỞI TẠO TRẠNG THÁI VÀ CÁC HÀM KHÁC ////////////////
local farmState = { LobbyAction = "NeedsToCreate", InMatch = false }
local function waitgameisloaded() customLog("⏳ Chờ game tải..."); if not game:IsLoaded() then game.Loaded:Wait() end; wait(3); customLog("✅ Game đã tải!") end
local function handleDialogues() customLog("🔎 Kiểm tra hội thoại..."); local playerGui=game:GetService("Players").LocalPlayer.PlayerGui; local DialogueEvent=game:GetService("ReplicatedStorage").Networking.State.DialogueEvent; local dialogueFound=false; local okayButton=playerGui:FindFirstChild("Dialogue",true) and playerGui.Dialogue:FindFirstChild("Dialogue",true) and playerGui.Dialogue.Dialogue:FindFirstChild("Options",true) and playerGui.Dialogue.Dialogue.Options:FindFirstChild("Option1",true) and playerGui.Dialogue.Dialogue.Options.Option1:FindFirstChild("Okay!"); if okayButton and okayButton.Parent then dialogueFound=true; customLog("✅ Xử lý 'Okay!'..."); pcall(function() DialogueEvent:FireServer("Interact", {"StarterUnitDialogue", 1, "Okay!"}) end); wait(8) end; local yeahButton=playerGui:FindFirstChild("Dialogue",true) and playerGui.Dialogue:FindFirstChild("Dialogue",true) and playerGui.Dialogue.Dialogue:FindFirstChild("Options",true) and playerGui.Dialogue.Dialogue.Options:FindFirstChild("Option1",true) and playerGui.Dialogue.Dialogue.Options.Option1:FindFirstChild("Yeah!"); if yeahButton and yeahButton.Parent then dialogueFound=true; customLog("✅ Xử lý 'Yeah!'..."); pcall(function() DialogueEvent:FireServer("Interact", {"StarterUnitDialogue", 2, "Yes!"}) end) else if dialogueFound then warn("⚠️ Không thấy hội thoại 'Yeah!'.") end end; return dialogueFound end
local function claimNewPlayerReward() customLog("🔎 Kiểm tra phần thưởng..."); pcall(function() local dayIndicatorPath=game:GetService("Players").LocalPlayer.PlayerGui.NewPlayers.Holder.TopRewards.SmallTemplate.SmallTemplate.Main.Day; if dayIndicatorPath then customLog("🎁 Nhận thưởng ngày 1..."); local remote=game:GetService("ReplicatedStorage").Networking.NewPlayerRewardsEvent; remote:FireServer("Claim", 1); customLog("✅ Đã nhận."); wait(3) end end) end
local function selectStartingUnit_Roku() customLog("📌 Chọn unit 'Roku'..."); pcall(function() local remote=game:GetService("ReplicatedStorage").Networking.Units.UnitSelectionEvent; remote:FireServer("Select", "Roku"); customLog("✅ Đã chọn.") end) end
local function checkAndEquipUnits() customLog("🛡️ Trang bị units..."); local success, err = pcall(function() local EquipEvent = game:GetService("ReplicatedStorage").Networking.Units.EquipEvent; local ROKU_EQUIP_ID = "f7d74383-6d36-4dfc-99f5-17a8455b1db6"; local ACKER_EQUIP_ID = "12c3a768-6677-4436-8ab2-5fcd895c3cd1"; EquipEvent:FireServer("Equip", ROKU_EQUIP_ID); customLog("⬆️ Gửi equip Roku."); wait(0.7); EquipEvent:FireServer("Equip", ACKER_EQUIP_ID); customLog("⬆️ Gửi equip Acker."); wait(0.7); customLog("✅ Xong trang bị.") end); if not success then warn("⚠️ Lỗi trang bị:", err) end end

local LOBBY_PLACE_ID = 16146832113; local MATCH_PLACE_ID = 16277809958
customLog("🟢 Script đã kích hoạt!")
waitgameisloaded()

-- ##################################################################
-- #                     VÒNG LẶP CHÍNH CỦA SCRIPT                  #
-- ##################################################################
while _G.DarcyFarmControl.State == "Running" do -- Thay đổi điều kiện dừng
    local currentPlaceId = game.PlaceId
    if currentPlaceId == LOBBY_PLACE_ID then
        farmState.InMatch = false
        if farmState.LobbyAction == "NeedsToCreate" then
            farmState.LobbyAction = "WaitingForTeleport"; customLog("🏠 Đang ở Lobby...")
            local isNewPlayer = handleDialogues()
            if isNewPlayer then
                customLog("✨ Luồng người chơi mới...")
                customLog("⏳ Chờ 5s..."); wait(5); selectStartingUnit_Roku()
                customLog("⏳ Chờ 5s..."); wait(5); claimNewPlayerReward()
                checkAndEquipUnits(); customLog("⏳ Chờ 5s..."); wait(5)
            else
                customLog("🔄 Người chơi cũ."); checkAndEquipUnits(); wait(2)
            end
            customLog("➡️ Tạo trận..."); pcall(function() local lobbyEvent = game:GetService("ReplicatedStorage").Networking.LobbyEvent; local addMatchArgs = { [1] = "AddMatch", [2] = { ["Difficulty"] = "Normal", ["Act"] = "Act1", ["StageType"] = "Story", ["Stage"] = "Stage1", ["FriendsOnly"] = false } }; lobbyEvent:FireServer(unpack(addMatchArgs)); customLog("➕ Đã tạo trận."); wait(3); lobbyEvent:FireServer("StartMatch"); customLog("🚀 Đã bắt đầu trận!") end)
        end
    elseif currentPlaceId == MATCH_PLACE_ID and not farmState.InMatch then
        farmState.InMatch = true; customLog("⚔️ Đã vào trận.")
        local hasCompletedFirstRun = false
        customLog("⏳ Chờ 20 giây..."); wait(20)
        
        while currentPlaceId == MATCH_PLACE_ID and _G.DarcyFarmControl.State == "Running" do
            customLog("🔥 Bắt đầu lượt chơi mới...")
            spawn(function() pcall(function() local skipWaveGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("SkipWave", 45); if skipWaveGui and skipWaveGui.Parent and skipWaveGui:FindFirstChild("Holder") and skipWaveGui.Holder:FindFirstChild("Yes") then game:GetService("ReplicatedStorage").Networking.SkipWaveEvent:FireServer("Skip") end end) end)
            customLog("⏳ Chờ 3 giây..."); wait(3)
            do -- Khối logic đặt và nâng cấp unit
                local unitState = { isRokuPlaced = false, isAckerPlaced = false, ackerUpgradeLevel = 0 }; local ACKER_INSTANCE = nil; local ROKU_COST = 400; local ACKER_COST = 1000; local ACKER_UPGRADES = { [1] = 2400, [2] = 3600, [3] = 5200 }; local ROKU_POSITION = Vector3.new(431.536, 4.840, -358.474); local ACKER_POSITION = Vector3.new(445.913, 3.529, -345.790); local UnitEvent = game:GetService("ReplicatedStorage").Networking.UnitEvent
                local function getCurrentMoney() local moneyAmount=0; pcall(function() local lbl=game:GetService("Players").LocalPlayer.PlayerGui.Hotbar.Main.Yen; local str=string.gsub(lbl.Text,"[^%d]",""); moneyAmount=tonumber(str) or 0 end); return moneyAmount end
                local function getUnitInstanceAtPosition(position) local unitsFolder = workspace:FindFirstChild("Units"); if not unitsFolder then return nil end; for _, unit in ipairs(unitsFolder:GetChildren()) do local unitRoot = unit:FindFirstChild("HumanoidRootPart") or unit.PrimaryPart; if unitRoot and (unitRoot.Position - position).Magnitude < 1 then customLog("✅ 'Săn' ID Acker: "..unit.Name); return unit end end; return nil end
                while unitState.ackerUpgradeLevel < 3 and _G.DarcyFarmControl.State == "Running" and currentPlaceId == MATCH_PLACE_ID do
                    local currentMoney = getCurrentMoney()
                    if not unitState.isRokuPlaced and currentMoney >= ROKU_COST then customLog(string.format("💰 (%d/%d) Đặt Roku...", currentMoney, ROKU_COST)); UnitEvent:FireServer("Render", {"Roku", 41, ROKU_POSITION, 0}); unitState.isRokuPlaced = true
                    elseif unitState.isRokuPlaced and not unitState.isAckerPlaced and currentMoney >= ACKER_COST then customLog(string.format("💰 (%d/%d) Đặt Acker...", currentMoney, ACKER_COST)); UnitEvent:FireServer("Render", {"Ackers", 241, ACKER_POSITION, 0}); unitState.isAckerPlaced = true; wait(1.5); ACKER_INSTANCE = getUnitInstanceAtPosition(ACKER_POSITION)
                    elseif ACKER_INSTANCE and unitState.ackerUpgradeLevel < 3 then
                        local nextUpgradeLevel = unitState.ackerUpgradeLevel + 1; local upgradeCost = ACKER_UPGRADES[nextUpgradeLevel]
                        if currentMoney >= upgradeCost then customLog(string.format("💰 (%d/%d) Nâng cấp Acker #%d...", currentMoney, upgradeCost, nextUpgradeLevel)); UnitEvent:FireServer("Upgrade", ACKER_INSTANCE.Name); unitState.ackerUpgradeLevel = nextUpgradeLevel end
                    end; wait(0.5); currentPlaceId = game.PlaceId
                end; customLog("✅ Xong đặt/nâng cấp.")
            end
            
            if not hasCompletedFirstRun then
                customLog("⏳ (Lượt đầu) Chờ RewardsDisplay...")
                local rewardsDisplay = game.Players.LocalPlayer.PlayerGui:WaitForChild("RewardsDisplay", 1200)
                if rewardsDisplay and rewardsDisplay.Parent and _G.DarcyFarmControl.State == "Running" then customLog("🏆 Gửi Retry..."); wait(1); pcall(function() game:GetService("ReplicatedStorage").Networking.EndScreen.VoteEvent:FireServer("Retry"); customLog("🔄 Đã Retry!") end); hasCompletedFirstRun = true; wait(5)
                else customLog("❌ Không thấy màn hình thưởng."); break end
            else
                customLog("⏳ (Lượt sau) Chờ EndScreen...")
                local endScreenGui; while _G.DarcyFarmControl.State == "Running" and not (endScreenGui and endScreenGui.Parent) do endScreenGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("EndScreen"); wait(0.5) end
                if _G.DarcyFarmControl.State == "Running" and endScreenGui then
                    local holder = endScreenGui:FindFirstChild("Holder"); if holder and holder:FindFirstChild("Buttons") and holder.Buttons:FindFirstChild("Retry") then customLog("✅ Thấy nút Retry! Gửi Retry..."); wait(3); pcall(function() game:GetService("ReplicatedStorage").Networking.EndScreen.VoteEvent:FireServer("Retry"); customLog("🔄 Đã Retry!") end); wait(5)
                    else customLog("❌ Không thấy nút Retry."); break end
                else customLog("❌ Không thấy EndScreen."); break end
            end
            currentPlaceId = game.PlaceId
        end
        customLog("🚪 Thoát vòng lặp farm nội bộ."); farmState.LobbyAction = "NeedsToCreate"
    end
    wait(2)
end
customLog("⏹️ Script đã dừng.")
if _G.DarcyFarmControl.GUI and _G.DarcyFarmControl.GUI.Parent then _G.DarcyFarmControl.GUI:Destroy() end
