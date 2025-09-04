local assetDeliveryBehaviour = require("./assetdelivery")
local gamesBehaviour = require("./games")

-- Map assetTypeId -> XML property to look for
local TEMPLATE_TAGS = {
	["Texture"] = "Texture",
	["Shirt"] = "ShirtTemplate",
	["Pants"] = "PantsTemplate",
}

local Client = {}

Client.Interface = {}
Client.Prototype = {}
Client.__type = "RobloxClient"

function Client.Prototype.getClothingTemplate(self: Client, assetId: number, download: boolean?)
	local assetData = self:fetchAsset(assetId)
	local assetInfo = self:fetchAssetInfo(assetId)

	if not (assetData.success and assetInfo.success) then
		return
	end

	local assetInfoData = assetInfo.data
	local assetDataData = assetData.data

	local templateTag = TEMPLATE_TAGS[assetInfoData.assetType]

	if not templateTag then
		error(`assetId must be a Texture, ShirtTemplate or PantsTemplate`)
	end

	local innerUrl = assetDataData:match('<Content name="' .. templateTag .. '">.-<url>(.-)</url>')

	local nestedId = innerUrl:match("id=(%d+)")
	if not nestedId then
		error("Could not extract nested assetId from template")
	end

	local assetImageData = self:fetchAssetUrl(tonumber(nestedId) :: number)

	if not assetImageData.success then
		error("Could not fetch asset data")
	end

	return assetImageData.data
end

function Client.Prototype.setCookie(self: Client, cookie: string): Client
	self.cookie = cookie

	return self
end

function Client.Prototype.setApiKey(self: Client, api_key: string): Client
	self.api_key = api_key

	return self
end

function Client.Prototype.sync(self: Client)
	assetDeliveryBehaviour.inheritMethods(self)
	gamesBehaviour.inheritMethods(self)
end

function Client.Interface.new(cookie: string?, api_key: string?): Client
	local self = setmetatable({
		cookie = cookie,
		api_key = api_key,
	}, {
		__index = Client.Prototype,
	})

	self:sync()

	return self
end

export type Client = typeof(Client.Prototype) & {
	cookie: string,
	api_key: string,
} & assetDeliveryBehaviour.AssetDeliveryBehaviour & gamesBehaviour.GamesBehaviour

return Client.Interface
