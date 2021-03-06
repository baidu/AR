function LOAD_WEBVIEW()
	WebView = {
		__call = function (self,entity)
			local webview = {
				_entity = nil,
				_url = "",
				_width = 0,
				_height = 0,
				_is_remote = 0,
				_webview_id = -1,

				url = function (self,string)
					self._url = string
					return self
				end,

				is_remote = function (self,value)
					self._is_remote = value
					return self
				end,

				width = function (self,value)
					ARLOG('load width:'..value)
					self._width = value
					return self
				end,

				height = function (self,value)
					self._height = value
					return self
				end,

				load = function (self)
					ARLOG('webview load:')
					local texture_id = self._entity:get_texture_id('uWebViewTexture')
					local mapData = ae.MapData:new()
					ARLOG('webview send_message_tosdk:'..texture_id)
					mapData:put_int("id", MSG_TYPE_WEBVIEW_OPERATION)
					mapData:put_int("operation", WebViewOperation.WebViewLoad)
					mapData:put_int("texture_id", texture_id)
					mapData:put_int('width', self._width)
					mapData:put_int('height', self._height)
					mapData:put_int('is_remote', self._is_remote)
					mapData:put_string("url", self._url)
					ARLOG('webview send_message_tosdk:')
					WebView.WebViewDict[texture_id] = self
					AR.current_application.lua_handler:send_message_tosdk(mapData)
					return self
				end,

			}

			webview._entity = entity
			
			webview.update_model = function(self,value)
				local mapData = ae.MapData:new()
				local texture_id = self._entity:get_texture_id('uWebViewTexture')
				mapData:put_int("id", MSG_TYPE_WEBVIEW_OPERATION)
				mapData:put_int("texture_id", texture_id)
				mapData:put_int("operation", WebViewOperation.ModelUpdate)
				mapData:put_string("js_code", value)
				AR.current_application.lua_handler:send_message_tosdk(mapData)
				return self
			end

			webview.update_texture = function(self) 
				local texture_id = self._entity:get_texture_id('uWebViewTexture')
				ARLOG('WebView update_texture:'..texture_id)
				self._entity:update_webview_texture(texture_id)
				return self
			end

			webview.on_load_finish = function(self)
				self:update_texture()
			end

			return webview
		end,

		WebViewLoaded = function(self, texture_id)
			ARLOG('WebView WebViewLoaded:'..texture_id)
			local webview = self.WebViewDict[texture_id]
			if WebView ~= nil then
				ARLOG('WebView on_loal_finish:'..texture_id)
				webview:on_load_finish()
			end
		end,

		WebViewUpdateFinished = function(self, texture_id)
			ARLOG('WebView WebViewUpdateFinished:'..texture_id)
			local webview = self.WebViewDict[texture_id]
			if WebView ~= nil then
				ARLOG('WebView on_loal_finish:'..texture_id)
				webview:on_load_finish()
			end
		end,


		WebViewDict = {}
	}
	setmetatable(WebView,WebView)
	ARLOG('load WebView')
end
LOAD_WEBVIEW()
