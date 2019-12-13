local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")

local WebAPI = {}

local BASE_URL = ContentProvider.BaseUrl
for _, word in pairs({"/", "www.", "https:", "http:" }) do
	BASE_URL = string.gsub(BASE_URL, word, "")
end

local AVATAR_URL = "https://avatar." ..BASE_URL

WebAPI.Status = {
	PENDING = 0,
	UNKNOWN_ERROR = -1,
	NO_CONNECTIVITY = -2,
	INVALID_JSON = -3,
	BAD_TLS = -4,
	MODERATED = -5,

	OK = 200,
	BAD_REQUEST = 400,
	UNAUTHORIZED = 401,
	FORBIDDEN = 403,
	NOT_FOUND = 404,
	REQUEST_TIMEOUT = 408,
	INTERNAL_SERVER_ERROR = 500,
	NOT_IMPLEMENTED = 501,
	BAD_GATEWAY = 502,
	SERVICE_UNAVAILABLE = 503,
	GATEWAY_TIMEOUT = 504,
}

local function jsonDecode(data)
	return HttpService:JSONDecode(data)
end

local function getHttpStatus(response)
	for _, code in pairs(WebAPI.Status) do
		if code >= 100 and response:find(tostring(code)) then
			return code
		end
	end

	if response:find("2%d%d") then
		return WebAPI.Status.OK
	end

	if response:find("curl_easy_perform") and response:find("SSL") then
		return WebAPI.Status.BAD_TLS
	end

	return WebAPI.Status.UNKNOWN_ERROR
end

local function httpGet(url)
	return game:HttpGetAsync(url)
end

local function httpGetJson(url)
	local success, response = pcall(httpGet, url)
	local status = success and WebAPI.Status.OK or getHttpStatus(response)

	if success then
		success, response = pcall(jsonDecode, response)
		status = success and status or WebAPI.Status.INVALID_JSON
	end

	return response, status
end

local function getData(url)
	local result, status = httpGetJson(url)
	return status, result
end

function WebAPI.GetAvatarRulesData()
	local status, result = getData(AVATAR_URL .. "/v1/avatar-rules")
	return status, result
end

return WebAPI
