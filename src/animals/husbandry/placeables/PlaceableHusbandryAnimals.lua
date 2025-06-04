MVA_PlaceableHusbandryAnimals = {}


function MVA_PlaceableHusbandryAnimals:startRiding(animalId, husbandryId, player)

	if self.isServer then

		local spec = self.spec_husbandryAnimals
		local cluster = spec.clusterSystem:getClusterById(animalId)

		if cluster ~= nil then

			local x, y, z, rx, ry, rz = spec.clusterHusbandry:getAnimalPosition(animalId, husbandryId)

			if x ~= nil then

				local farmId = self:getOwnerFarmId()
				local filename = cluster:getRidableFilename()
				cluster:changeNumAnimals(-1)
				spec.clusterSystem:updateNow()

				local vehicleLoadingData = VehicleLoadingData.new()

				vehicleLoadingData:setFilename(filename)
				vehicleLoadingData:setPosition(x, y, z)
				vehicleLoadingData:setRotation(rx, ry, rz)
				vehicleLoadingData:setPropertyState(VehiclePropertyState.OWNED)
				vehicleLoadingData:setOwnerFarmId(farmId)
				vehicleLoadingData:load(self.onLoadedRideable, self, {
					["player"] = player,
					["cluster"] = cluster
				})

			end

		end

	else
		g_client:getServerConnection():sendEvent(AnimalRidingEvent.new(self, animalId, husbandryId, player))
	end

end

PlaceableHusbandryAnimals.startRiding = Utils.overwrittenFunction(PlaceableHusbandryAnimals.startRiding, MVA_PlaceableHusbandryAnimals.startRiding)