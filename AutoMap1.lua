-- ==========================================================
--        SCRIPT AUTO-FARM "TÀNG HÌNH" (PHIÊN BẢN CUỐI CÙNG)
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
        print("⏳ Chờ 20 giây để game ổn định và tải toàn bộ GUI...")
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
            
            wait(3)

            -- ====================================================================================
            --        <<< BẮT ĐẦU KHỐI LOGIC ĐẶT & NÂNG CẤP UNIT (SỬA LỖI ID ĐỘNG) >>>
            -- ====================================================================================
            do
                local unitState = { isRokuPlaced = false, isAckerPlaced = false, ackerUpgradeLevel = 0 }
                local ACKER_INSTANCE = nil -- Biến này sẽ lưu unit Acker thật sự
                local ROKU_COST = 400; local ACKER_COST = 1000
                local ACKER_UPGRADES = { [1] = 2400, [2] = 3600, [3] = 5200 }
                local ROKU_POSITION = Vector3.new(431.536, 4.840, -358.474)
                local ACKER_POSITION = Vector3.new(445.913, 3.529, -345.790)
                local UnitEvent = game:GetService("ReplicatedStorage").Networking.UnitEvent
                
                local function getCurrentMoney() local moneyAmount=0; pcall(function() local lbl=game:GetService("Players").LocalPlayer.PlayerGui.Hotbar.Main.Yen; local str=string.gsub(lbl.Text,"[^%d]",""); moneyAmount=tonumber(str) or 0 end); return moneyAmount end
                
                -- HÀM "SĂN" UNIT ĐÃ ĐƯỢC CẬP NHẬT
                local function getUnitInstanceAtPosition(position)
                    print("🎯 Đang 'săn' unit tại vị trí:", position)
                    local unitsFolder = workspace:FindFirstChild("Units") -- << SỬ DỤNG ĐÚNG PATH BẠN CUNG CẤP
                    if not unitsFolder then warn("⚠️ Không tìm thấy thư mục 'Units' trong workspace!"); return nil end
                    for _, unit in ipairs(unitsFolder:GetChildren()) do
                        local unitRoot = unit:FindFirstChild("HumanoidRootPart") or unit.PrimaryPart
                        if unitRoot and (unitRoot.Position - position).Magnitude < 1 then
                            print("✅ Đã tìm thấy unit! ID mới là:", unit.Name); return unit
                        end
                    end
                    warn("⚠️ Không tìm thấy unit nào tại vị trí đã chỉ định."); return nil
                end

                while unitState.ackerUpgradeLevel < 3 and _G.DarcyFarmIsRunning do
                    local currentMoney = getCurrentMoney()
                    if not unitState.isRokuPlaced and currentMoney >= ROKU_COST then
                        print(string.format("💰 Đủ tiền (%d/%d). Đặt Roku...", currentMoney, ROKU_COST))
                        UnitEvent:FireServer("Render", {"Roku", 41, ROKU_POSITION, 0}); unitState.isRokuPlaced = true
                    elseif unitState.isRokuPlaced and not unitState.isAckerPlaced and currentMoney >= ACKER_COST then
                        print(string.format("💰 Đủ tiền (%d/%d). Đặt Acker...", currentMoney, ACKER_COST))
                        UnitEvent:FireServer("Render", {"Ackers", 241, ACKER_POSITION, 0}); unitState.isAckerPlaced = true
                        wait(1.5) -- Chờ unit xuất hiện
                        ACKER_INSTANCE = getUnitInstanceAtPosition(ACKER_POSITION) -- "Săn" ID ngay lập tức
                    elseif ACKER_INSTANCE and unitState.ackerUpgradeLevel < 3 then
                        local nextUpgradeLevel = unitState.ackerUpgradeLevel + 1
                        local upgradeCost = ACKER_UPGRADES[nextUpgradeLevel]
                        if currentMoney >= upgradeCost then
                            print(string.format("💰 Đủ tiền (%d/%d). Nâng cấp Acker (ID: %s)...", currentMoney, upgradeCost, ACKER_INSTANCE.Name))
                            UnitEvent:FireServer("Upgrade", ACKER_INSTANCE.Name); unitState.ackerUpgradeLevel = nextUpgradeLevel
                        end
                    end
                    wait(0.5)
                end
                print("✅ Hoàn thành quy trình đặt và nâng cấp unit.")
            end
            
            -- >> LOGIC CHỜ ENDSCREEN VÀ RETRY SẼ NẰM Ở ĐÂY <<
            break
        end
        print("🚪 Đã thoát khỏi vòng lặp farm nội bộ."); farmState.LobbyAction = "NeedsToCreate"
    end
    wait(2)
end
print("⏹️ Script đã dừng hẳn theo lệnh.")
