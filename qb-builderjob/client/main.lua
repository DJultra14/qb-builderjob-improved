QBCore = nil
isLoggedIn = false
PlayerData = {}
local isBuilder = false
local PlayerJob = {}
local BuilderBlip = nil
local CurrentBlip = nil
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if QBCore == nil then
            TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
            Citizen.Wait(200)
        end
    end
end)

-- Code

local BuilderData = {
    ShowDetails = false,
    CurrentTask = nil,
}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerData = QBCore.Functions.GetPlayerData()
    GetCurrentProject()
end)

Citizen.CreateThread(function()
    Wait(1000)
    isLoggedIn = true
    PlayerData = QBCore.Functions.GetPlayerData()
    GetCurrentProject()
end)

function GetCurrentProject()
    QBCore.Functions.TriggerCallback('qb-builderjob:server:GetCurrentProject', function(BuilderConfig)
        Config = BuilderConfig
    end)
end

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function GetCompletedTasks()
    local retval = {
        completed = 0,
        total = #Config.Projects[Config.CurrentProject].ProjectLocations["tasks"]
    }
    for k, v in pairs(Config.Projects[Config.CurrentProject].ProjectLocations["tasks"]) do
        if v.completed then
            retval.completed = retval.completed + 1
        end
    end
    return retval
end

Citizen.CreateThread(function()
    while true do
        
        
        if isBuilder then

            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local inRange = false
            local OffsetZ = 0.2
            
            if Config.CurrentProject ~= 0 then
                local data = Config.Projects[Config.CurrentProject].ProjectLocations["main"]
                local MainDistance = #(pos - vector3(data.coords.x, data.coords.y, data.coords.z))

                if MainDistance < 10 then
                    inRange = true
                    DrawMarker(2, data.coords.x, data.coords.y, data.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 55, 155, 255, 255, 0, 0, 0, 1, 0, 0, 0)

                    if MainDistance < 2 then
                        local TaskData = GetCompletedTasks()
                        if TaskData ~= nil then
                            if not BuilderData.ShowDetails then
                                DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '[E] Detail view')
                                DrawText3Ds(data.coords.x, data.coords.y, data.coords.z + 0.2, 'Exercises: '..TaskData.completed..' / '..TaskData.total)
                            else
                                DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '[E] Details hide')
                                for k, v in pairs(Config.Projects[Config.CurrentProject].ProjectLocations["tasks"]) do
                                    if v.completed then
                                        DrawText3Ds(data.coords.x, data.coords.y, data.coords.z + OffsetZ, v.label..': Completed')
                                    else
                                        DrawText3Ds(data.coords.x, data.coords.y, data.coords.z + OffsetZ, v.label..': Not completed')
                                    end
                                    OffsetZ = OffsetZ + 0.2
                                end
                            end

                            if TaskData.completed == TaskData.total then
                                DrawText3Ds(data.coords.x, data.coords.y, data.coords.z - 0.2, '[G] End project')
                                if IsControlJustPressed(0, 47) then
                                    TriggerServerEvent('qb-builderjob:server:FinishProject')
                                end
                            end

                            if IsControlJustPressed(0, 38) then
                                BuilderData.ShowDetails = not BuilderData.ShowDetails
                            end
                        end
                    end
                end

                for k, v in pairs(Config.Projects[Config.CurrentProject].ProjectLocations["tasks"]) do
                    if not v.completed or not v.IsBusy then
                        local TaskDistance = #(pos - vector3(v.coords.x, v.coords.y, v.coords.z))
                        if TaskDistance < 10 then
                            inRange = true
                            DrawMarker(2, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 55, 155, 255, 255, 0, 0, 0, 1, 0, 0, 0)
                            if TaskDistance < 1.5 then
                                DrawText3Ds(v.coords.x, v.coords.y, v.coords.z + 0.25, '[E] Complete task '.. v.label)
                                if IsControlJustPressed(0, 38) then
                                    BuilderData.CurrentTask = k
                                    DoTask()
                                end
                            end
                        end
                    end
                end
            end

            if not inRange then
                Citizen.Wait(1000)
            end
        end
    Citizen.Wait(3)
    end
end)

function DoTask()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local TaskData = Config.Projects[Config.CurrentProject].ProjectLocations["tasks"][BuilderData.CurrentTask]
    
    TriggerServerEvent('qb-builderjob:server:SetTaskState', BuilderData.CurrentTask, true, false)

    if TaskData.type == "hammer" then     
        TaskStartScenarioAtPosition(ped, "WORLD_HUMAN_HAMMERING", TaskData.coords.x, TaskData.coords.y, TaskData.coords.z, TaskData.coords.h, nil, false, true )     
    end

    if TaskData.type == "look" then      
        TaskStartScenarioAtPosition(ped, "CODE_HUMAN_POLICE_INVESTIGATE", TaskData.coords.x, TaskData.coords.y, TaskData.coords.z, TaskData.coords.h, nil, false, true )       
    end

    if TaskData.type == "mix" then      
        TaskStartScenarioAtPosition(ped, "PROP_HUMAN_BUM_BIN", TaskData.coords.x, TaskData.coords.y, TaskData.coords.z, TaskData.coords.h, nil, false, true )       
    end

    if TaskData.type == "janitor" then      
        TaskStartScenarioAtPosition(ped, "WORLD_HUMAN_JANITOR", TaskData.coords.x, TaskData.coords.y, TaskData.coords.z, TaskData.coords.h, nil, false, true )       
    end

    if TaskData.type == "drill" then      
        TaskStartScenarioAtPosition(ped, "WORLD_HUMAN_CONST_DRILL", TaskData.coords.x, TaskData.coords.y, TaskData.coords.z, TaskData.coords.h, nil, false, true )       
    end

    if TaskData.type == "weld" then      
        TaskStartScenarioAtPosition(ped, "WORLD_HUMAN_WELDING", TaskData.coords.x, TaskData.coords.y, TaskData.coords.z, TaskData.coords.h, nil, false, true )       
    end

    Citizen.Wait(10000)
    ClearPedTasksImmediately(ped)
    TriggerServerEvent('qb-builderjob:server:SetTaskState', BuilderData.CurrentTask, true, true)
end

RegisterNetEvent('qb-builderjob:client:SetTaskState')
AddEventHandler('qb-builderjob:client:SetTaskState', function(Task, IsBusy, IsCompleted)
    Config.Projects[Config.CurrentProject].ProjectLocations["tasks"][Task].IsBusy = IsBusy
    Config.Projects[Config.CurrentProject].ProjectLocations["tasks"][Task].completed = IsCompleted
end)

RegisterNetEvent('qb-builderjob:client:FinishProject')
AddEventHandler('qb-builderjob:client:FinishProject', function(BuilderConfig)
    Config = BuilderConfig
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    
    PlayerJob = QBCore.Functions.GetPlayerData().job
    local data = Config.Projects[Config.CurrentProject].ProjectLocations["main"]
    CurrentBlip = nil
    
    

    if PlayerJob.name == "builder" then
        BuilderBlip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(BuilderBlip, 402)
        SetBlipDisplay(BuilderBlip, 4)
        SetBlipScale(BuilderBlip, 1.2)
        SetBlipAsShortRange(BuilderBlip, true)
        SetBlipColour(BuilderBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Config.Locations["vehicle"].label)
        EndTextCommandSetBlipName(BuilderBlip)
        setbuilder(true)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    RemoveBuilderBlips()
    CurrentLocation = nil
    CurrentBlip = nil
    hasBox = false
    isWorking = false
    JobsDone = 0
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    local OldPlayerJob = PlayerJob.name
    PlayerJob = JobInfo
    local data = Config.Projects[Config.CurrentProject].ProjectLocations["main"]
    
    if PlayerJob.name == "builder" then
        BuilderBlip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(BuilderBlip, 402)
        SetBlipDisplay(BuilderBlip, 4)
        SetBlipScale(BuilderBlip, 1.2)
        SetBlipAsShortRange(BuilderBlip, true)
        SetBlipColour(BuilderBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Work Site")
        EndTextCommandSetBlipName(BuilderBlip)
        setbuilder(true)
        
    elseif OldPlayerJob == "builder" then
        RemoveBuilderBlips()
        setbuilder(false)
    end
end)

function setbuilder(bool)

    
    isBuilder = bool
    
end

function RemoveBuilderBlips()
    if BuilderBlip ~= nil then
        RemoveBlip(BuilderBlip)
        BuilderBlip = nil
    end

    if CurrentBlip ~= nil then
        RemoveBlip(CurrentBlip)
        CurrentBlip = nil
    end
end