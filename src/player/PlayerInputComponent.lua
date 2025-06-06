MVA_PlayerInputComponent = {}


function MVA_PlayerInputComponent:update()

    if self.player.isOwner then

        if g_inputBinding:getContextName() == PlayerInputComponent.INPUT_CONTEXT_NAME then

            local currentMission = g_currentMission
            local accessHandler = currentMission.accessHandler
            local vehicleInRange = currentMission.interactiveVehicleInRange
            local canAccess

            if vehicleInRange == nil then
                canAccess = false
            else
                canAccess = accessHandler:canPlayerAccess(vehicleInRange, self.player)
            end

            local closestNode = self.player.targeter:getClosestTargetedNodeFromType(PlayerInputComponent)
            self.player.hudUpdater:setCurrentRaycastTarget(closestNode)

            if not canAccess and closestNode ~= nil then

                local husbandryId, animalId = getAnimalFromCollisionNode(closestNode)

                if husbandryId ~= nil and husbandryId ~= 0 then

                    local clusterHusbandry = currentMission.husbandrySystem:getClusterHusbandryById(husbandryId)

                    if clusterHusbandry ~= nil then

                        local placeable = clusterHusbandry:getPlaceable()
                        local animal = clusterHusbandry:getClusterByAnimalId(animalId, husbandryId)

                        if animal ~= nil and (accessHandler:canFarmAccess(self.player.farmId, placeable) and animal:getRidableFilename() ~= nil) then

                            self.rideablePlaceable = placeable
                            self.rideableCluster = animal
                            self.rideableHusbandry = husbandryId

                            local name = animal.getName == nil and "" or animal:getName()
                            local text = string.format(g_i18n:getText("action_rideAnimal"), name)

                            g_inputBinding:setActionEventText(self.enterActionId, text)
                            g_inputBinding:setActionEventActive(self.enterActionId, true)

                        end

                    end

                end

            end

        end

    end

end

PlayerInputComponent.update = Utils.appendedFunction(PlayerInputComponent.update, MVA_PlayerInputComponent.update)


function MVA_PlayerInputComponent:registerGlobalPlayerActionEvents()

    VisualAnimalsDialog.register()

    g_inputBinding:registerActionEvent(InputAction.mva_VisualAnimalsDialog, VisualAnimalsDialog, VisualAnimalsDialog.show, false, true, false, true, nil, true)

end


PlayerInputComponent.registerGlobalPlayerActionEvents = Utils.appendedFunction(PlayerInputComponent.registerGlobalPlayerActionEvents, MVA_PlayerInputComponent.registerGlobalPlayerActionEvents)


function MVA_PlayerInputComponent:onFinishedRideBlending(_, args)

    MVA_PlaceableHusbandryAnimals.startRiding(args[1], args[2].id, args[3], args[4])

end

PlayerInputComponent.onFinishedRideBlending = Utils.overwrittenFunction(PlayerInputComponent.onFinishedRideBlending, MVA_PlayerInputComponent.onFinishedRideBlending)


function MVA_PlayerInputComponent:onInputEnter()

	if g_time <= g_currentMission.lastInteractionTime + 200 then return end
	
    if g_currentMission.interactiveVehicleInRange == nil then

		if self.rideablePlaceable ~= nil then

			if self.rideablePlaceable:getAnimalCanBeRidden(self.rideableCluster.id) then

				g_inputBinding:setContext(PlayerInputComponent.INPUT_CONTEXT_NAME_ANIMAL_RIDING, true, false)
				g_currentMission:fadeScreen(1, 250, self.onFinishedRideBlending, self, { self.rideablePlaceable, self.rideableCluster, self.rideableHusbandry, self.player })
				return

			end

			g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_CRITICAL, g_i18n:getText("shop_messageAnimalRideableLimitReached"))
		end

	else
		g_currentMission.interactiveVehicleInRange:interact(self.player)
	end

end

PlayerInputComponent.onInputEnter = Utils.overwrittenFunction(PlayerInputComponent.onInputEnter, MVA_PlayerInputComponent.onInputEnter)