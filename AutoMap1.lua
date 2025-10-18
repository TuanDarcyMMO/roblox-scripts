-- ==========================================================
--        SCRIPT AUTO-FARM "Tàng Hình" (SỬA LOGIC LOBBY)
--        Author: Darcy & Gemini
--        Last Updated: 18/10/2025
-- ==========================================================

-- //////////////// KIỂM TRA VÀ DỪNG SCRIPT CŨ ////////////////
if _G.DarcyFarmIsRunning then print("🔴 Dừng script cũ..."); _G.DarcyFarmIsRunning = false; wait(1) end
_G.DarcyFarmIsRunning = true
-------------------------------------------------------------

-- //////////////// KHỞI TẠO TRẠNG THÁI VÀ CÁC HÀM ////////////////
local farmState = { LobbyAction = "NeedsToCreate", InMatch = false }
local function waitgameisloaded() print("⏳ Chờ game tải..."); if not game:IsLoaded() then game.Loaded:Wait() end; wait(3); print("✅ Game đã tải!") end

-- <<< HÀM XỬ LÝ HỘI THOẠI (SẼ TRẢ VỀ TRUE NẾU CÓ HỘI THOẠI) >>>
local function handleDialogues()
    print("🔎 Kiểm tra hội thoại..."); local playerGui = game:GetService("Players").LocalPlayer.PlayerGui; local DialogueEvent = game:GetService("ReplicatedStorage").Networking.State.DialogueEvent; local dialogueFound = false
    local okayButton = playerGui:FindFirstChild("Dialogue", true) and playerGui.Dialogue:FindFirstChild("Dialogue", true) and playerGui.Dialogue.Dialogue:FindFirstChild("Options", true) and playerGui.Dialogue.Dialogue.Options:FindFirstChild("Option1", true) and playerGui.Dialogue.Dialogue.Options.Option1:FindFirstChild("Okay!")
    if okayButton and okayButton.Parent then dialogueFound = true; print("✅ Xử lý 'Okay!'..."); pcall(function() DialogueEvent:FireServer("Interact", {"StarterUnitDialogue", 1, "Okay!"}) end); wait(8) end
    local yeahButton = playerGui:FindFirstChild("Dialogue", true) and playerGui.Dialogue:FindFirstChild("Dialogue", true) and playerGui.Dialogue.Dialogue:FindFirstChild("Options", true) and playerGui.Dialogue.Dialogue.Options:FindFirstChild("Option1", true) and playerGui.Dialogue.Dialogue.Options.Option1:FindFirstChild("Yeah!")
    if yeahButton and yeahButton.Parent then dialogueFound = true; print("✅ Xử lý 'Yeah!'..."); pcall(function() DialogueEvent:FireServer("Interact", {"StarterUnitDialogue", 2, "Yes!"}) end); wait(8) end
    if dialogueFound then print("✅ Xử lý xong hội thoại.") else print("ℹ️ Không có hội thoại.") end
    return dialogueFound -- Trả về true nếu đã xử lý hội thoại
end
local function claimNewPlayerReward() print("🔎 Kiểm tra phần thưởng người chơi mới..."); local success, err = pcall(function() local dayIndicatorPath = game:GetService("Players").LocalPlayer.PlayerGui.NewPlayers.Holder.TopRewards.SmallTemplate.SmallTemplate.Main.Day; if dayIndicatorPath then print("🎁 Nhận thưởng ngày 1..."); local remote = game:GetService("ReplicatedStorage").Networking.NewPlayerRewardsEvent; remote:FireServer("Claim", 1); print("✅ Đã nhận."); wait(3) else print("ℹ️ Không có phần thưởng.") end end); if not success then print("⚠️ Lỗi kiểm tra phần thưởng:", err) end end
local function checkAndEquipUnits()
    print("🛡️ Trang bị units..."); local success, err = pcall(function() local EquipEvent = game:GetService("ReplicatedStorage").Networking.Units.EquipEvent; local ROKU_EQUIP_ID = "12c3a768-6677-4436-8ab2-5fcd895c3cd1"; local ACKER_EQUIP_ID = "f7d74383-6d36-4dfc-99f5-17a8455b1db6"; EquipEvent:FireServer("Equip", ROKU_EQUIP_ID); print("⬆️ Gửi lệnh equip Roku."); wait(0.5); EquipEvent:FireServer("Equip", ACKER_EQUIP_ID); print("⬆️ Gửi lệnh equip Acker."); wait(0.5); print("✅ Xong trang bị.") end); if not success then warn("⚠️ Lỗi trang bị:", err) end
end
local function selectStartingUnit_Roku() print("📌 Chọn unit khởi đầu 'Roku'..."); pcall(function() local remote = game:GetService("ReplicatedStorage").Networking.Units.UnitSelectionEvent; remote:FireServer("Select", "Roku"); print("✅ Đã chọn.") end); wait(5) end

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
            farmState.LobbyAction = "WaitingForTeleport"; print("🏠 Đang ở Lobby...")
            
            -- << BƯỚC 1: KIỂM TRA VÀ XỬ LÝ HỘI THOẠI >>
            local isNewPlayerFlow = handleDialogues() -- Hàm này sẽ trả về true nếu có hội thoại
            
            -- << BƯỚC 2: THỰC HIỆN CHUỖI HÀNH ĐỘNG DỰA TRÊN KẾT QUẢ BƯỚC 1 >>
            if isNewPlayerFlow then
                -- Nếu là người chơi mới (có hội thoại)
                print("✨ Phát hiện luồng người chơi mới!")
                selectStartingUnit_Roku() -- Chọn Roku ngay sau hội thoại
                claimNewPlayerReward()    -- Nhận thưởng người mới
                checkAndEquipUnits()      -- Trang bị Roku và Acker
                wait(5)                   -- Chờ 5 giây trước khi tạo trận
            else
                -- Nếu là người chơi cũ (không có hội thoại)
                print("🔄 Là người chơi cũ, chỉ cần trang bị lại unit.")
                checkAndEquipUnits()      -- Chỉ cần trang bị lại Roku và Acker
                wait(2)                   -- Chờ 2 giây
            end
            
            -- << BƯỚC 3: TẠO VÀ BẮT ĐẦU TRẬN (LUÔN CHẠY SAU KHI XỬ LÝ XONG BƯỚC 2) >>
            print("➡️ Chuẩn bị tạo trận...")
            pcall(function() local lobbyEvent = game:GetService("ReplicatedStorage").Networking.LobbyEvent; local addMatchArgs = { [1] = "AddMatch", [2] = { ["Difficulty"] = "Normal", ["Act"] = "Act1", ["StageType"] = "Story", ["Stage"] = "Stage1", ["FriendsOnly"] = false } }; lobbyEvent:FireServer(unpack(addMatchArgs)); print("➕ Đã tạo trận."); wait(3); lobbyEvent:FireServer("StartMatch"); print("🚀 Đã bắt đầu trận!") end)
        end
    elseif currentPlaceId == MATCH_PLACE_ID and not farmState.InMatch then
        farmState.InMatch = true; print("⚔️ Đã vào trận. Bắt đầu VÒNG LẶP FARM VÔ HẠN.")
        print("⏳ Chờ 20 giây để game ổn định..."); wait(20)
        
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
                    end; wait(0.5); currentPlaceId = game.PlaceId
                end; print("✅ Hoàn thành quy trình đặt và nâng cấp unit.")
            end
            print("⏳ Chờ màn hình nhận thưởng (RewardsDisplay) để retry...")
            local rewardsDisplay = game.Players.LocalPlayer.PlayerGui:WaitForChild("RewardsDisplay", 1200)
            if rewardsDisplay and rewardsDisplay.Parent and _G.DarcyFarmIsRunning then print("🏆 Phát hiện RewardsDisplay! Gửi lệnh Retry..."); wait(1); pcall(function() game:GetService("ReplicatedStorage").Networking.EndScreen.VoteEvent:FireServer("Retry"); print("🔄 Đã gửi yêu cầu 'Retry'!") end); wait(5)
            else print("❌ Không tìm thấy màn hình thưởng hoặc script đã bị dừng."); break end
        end
        print("🚪 Đã thoát khỏi vòng lặp farm nội bộ."); farmState.LobbyAction = "NeedsToCreate"
    end
    wait(2)
end
print("⏹️ Script đã dừng hẳn theo lệnh.")
