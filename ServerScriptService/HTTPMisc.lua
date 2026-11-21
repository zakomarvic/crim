local loc = {}

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

loc.GetISO = function()
	if RunService:IsStudio() then return "--" end
	local url = "https://find-any-ip-address-or-domain-location-world-wide.p.rapidapi.com/iplocation"
	local apikey = "873dbe322aea47f89dcf729dcc8f60e8" -- replace this with your API key
	local fullurl = url.."?apikey="..apikey -- your now concating the API key parameter in the url
	local rapidapiKey = "4922e76204mshece1313f07dfb9fp10c2e4jsn214f18a10c20" -- replace with your Rapid API key
	local headers = {
		["X-RapidAPI-Key"] = rapidapiKey,
	}
	
	local success, response = pcall(function()
		return HttpService:GetAsync(fullurl, true, headers)
	end)

	if success and response then
		local decodedResponse = HttpService:JSONDecode(response)
		print("server is in "..decodedResponse["countryISO2"])
		return decodedResponse["countryISO2"]
	else
		warn("Failed to fetch server location")
		return "--"
	end
end

loc.GetCTP = function()
	return false
	--if RunService:IsStudio() then return true end
	--local url = "https://pastebin.com/raw/MJmV6C10"

	--local success, response = pcall(function()
	--	return HttpService:GetAsync(url, true)
	--end)
	
	--if success and response then
	--	return response
	--else
	--	return false
	--end
end

return loc
