MVA_AnimalRidingEvent = {}


function AnimalRidingEvent.new(husbandry, clusterId, husbandryId, player)

	local self = AnimalRidingEvent.emptyNew()

	self.husbandry = husbandry
	self.clusterId = clusterId
	self.husbandryId = husbandryId
	self.player = player

	return self

end


function MVA_AnimalRidingEvent:readStream(_, streamId, connection)

	self.husbandry = NetworkUtil.readNodeObject(streamId)
	self.clusterId = streamReadInt32(streamId)
	self.husbandryId = streamReadInt32(streamId)
	self.player = NetworkUtil.readNodeObject(streamId)

	self:run(connection)

end

AnimalRidingEvent.readStream = Utils.overwrittenFunction(AnimalRidingEvent.readStream, MVA_AnimalRidingEvent.readStream)


function MVA_AnimalRidingEvent:writeStream(_, streamId, connection)

	NetworkUtil.writeNodeObject(streamId, self.husbandry)
	streamWriteInt32(streamId, self.clusterId)
	streamWriteInt32(streamId, self.husbandryId)
	NetworkUtil.writeNodeObject(streamId, self.player)

end

AnimalRidingEvent.readStream = Utils.overwrittenFunction(AnimalRidingEvent.readStream, MVA_AnimalRidingEvent.readStream)


function MVA_AnimalRidingEvent:run(_, connection)
	MVA_PlaceableHusbandryAnimals.startRiding(self.husbandry, self.clusterId, self.husbandryId, self.player)
end

AnimalRidingEvent.readStream = Utils.overwrittenFunction(AnimalRidingEvent.readStream, MVA_AnimalRidingEvent.readStream)