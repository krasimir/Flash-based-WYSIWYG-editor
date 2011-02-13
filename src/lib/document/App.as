package lib.document {
	
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	import mx.containers.Canvas;
	import mx.controls.RichTextEditor;
	import mx.core.UIComponent;
	
	public class App extends Canvas {
		
		private var _editor:RichTextEditor;
		private var _textToSend:String;
		private var _callback:String;
		private var _defaultText:String;
				
		public function App(rootLoaderInfo:LoaderInfo) {
			
			// getting the callback method which has to be fired when the user changes the content
			_callback = rootLoaderInfo.parameters.callback || "null";
			
			// resizing the App to fit the screen
			percentWidth = percentHeight = 100;
			
			// init the editor
			_editor = new RichTextEditor();
			_editor.title = "Text:"
			_editor.percentWidth = _editor.percentHeight = 100;
			_editor.addEventListener(Event.CHANGE, onTextChange);
			_editor.htmlText = _defaultText;
			addChild(_editor);
			
			// removing some of the editor's controls
			_editor.toolbar.removeChild(_editor.fontFamilyCombo);
			_editor.toolbar.removeChild(_editor.bulletButton);
			_editor.toolbar.removeChild(_editor.alignButtons);
			_editor.toolbar.removeChild(_editor.fontSizeCombo);
			// _editor.toolbar.removeChild(_editor.colorPicker);
			// _editor.toolbar.removeChild(_editor.linkTextInput);
			
			// setting styles of the editor's buttons
			_editor.boldButton.styleName = "button";
			_editor.italicButton.styleName = "button";
			_editor.underlineButton.styleName = "button";
			_editor.alignButtons.styleName = "button";
			
			// adding the callback of setText function, which is called from javascript
			if(isInBrowser()) {
				ExternalInterface.addCallback("setText", receiveText);
			}
			
		}
		private function onTextChange(e:Event):void {
			var str:String = _editor.htmlText;
			str = removeTagsFromString(str, ["TEXTFORMAT"]);
			str = removeAttributesFromString(str, ["SIZE", "FACE", "ALIGN", "LETTERSPACING", "KERNING"]);
			str = lowerCaseAllTags(str);
			send(str);
		}
		private function send(str:String):void {
			debug("send str=" + str);
			if(isInBrowser()) {
				ExternalInterface.call(_callback, str);
			}
		}
		private function receiveText(str:String):void {
			_editor.htmlText = str;
			send(str);
		}
		// utils
		private function isInBrowser():Boolean {
			return Capabilities.playerType == "StandAlone" ? false : true;
		}
		private function debug(str:String):void {
			trace("> " + str);
		}
		private function removeTagsFromString(text:String, tags:Array = null):String {
			if(text.length == 0) {
				return text;
			}
			if(tags == null) {
				var removeHTML:RegExp = new RegExp("<[^>]*>", "gi");
				text = text.replace(removeHTML, "");
			} else {
				var numOfTags:int = tags.length;
				for(var i:int=0; i<numOfTags; i++) {
					var tag:String = tags[i];
					removeHTML = new RegExp("<" + tag + "[^>]*>", "gi");
					text = text.replace(removeHTML, "");
					removeHTML = new RegExp("</" + tag + "[^>]*>", "gi");
					text = text.replace(removeHTML, "");
				}
			}
			return text;
		}
		private function lowerCaseAllTags(text:String):String {
			if(text.length == 0) {
				return text;
			}
			var removeHTML:RegExp = new RegExp("(<[^>]*>)", "gi");
			text = text.replace(removeHTML, function():String { return arguments[0].toLowerCase(); } );
			return text;
		}
		private function removeAttributesFromString(text:String, attributes:Array):String {
			if(text.length == 0) {
				return text;
			}
			var numOfAttr:int = attributes.length;
			for(var i:int=0; i<numOfAttr; i++) {
				var attr:String = attributes[i];
				var removeHTML:RegExp = new RegExp(attr + "=\"[0-9a-zA-Z ~!@#$%^&*()_+-]*\" ?", "gi");
				text = text.replace(removeHTML, "");
			}
			return text;
		}
		private function replaceInString(source:String, searchFor:String, replaceWith:String, caseSensitive:Boolean = true):String {
			var patt:RegExp = new RegExp(searchFor, "g" + (caseSensitive ? "" : "i"));
			return source.replace(patt, replaceWith); 

		}
	}
	
}