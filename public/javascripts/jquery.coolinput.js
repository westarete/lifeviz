/**
 * CoolInput Plugin
 *
 * @version 1.4 (05/09/2009)
 * @requires jQuery v1.2.6+
 * @author Alex Weber <alexweber.com.br>
 * @copyright Copyright (c) 2008-2009, Alex Weber
 * @see http://remysharp.com/2007/01/25/jquery-tutorial-text-box-hints/
 *
 * Distributed under the terms of the GNU General Public License
 * http://www.gnu.org/licenses/gpl-3.0.html
 *
 */

/**
 * This plugin enables predefined text to be applied to input fields when they are empty + some nice customization options
 *
 * @example $("#myinputbox").coolinput();
 * @desc Applies coolinput functionality to the input with id="myinputbox" with default options
 *
 * @example $("input:search").coolinput({
 *		blurClass: 'myclass',
 *		iconClass: 'search',
 *		clearOnSubmit: true
 *	});
 * @desc Applies coolinput functionality to the selected input boxes with custom options
 *
 * @param User-specified text hint
 * @param Source for the input hint (if not user specified)
 * @param Class to apply when blurred
 * @param Additional class to be applied
 * @param Clear input text on submit if it remains the default value?
 *
 * @return jQuery Object
 * @type jQuery
 *
 * @name jQuery.fn.coolinput
 * @cat Plugins/Forms
 */

(function($){
	$.fn.coolinput = function(options) {
		// default options
		// @note NEW in 1.4: 'hint' option can be specified to override the default hint
		var settings = {
			hint : null,			// manually specify a hint
			source	  : 'title', 	// attribute to be used as source for default text
			blurClass : 'blur', 	// class to apply to blurred input elements
			iconClass : false, 		// specifies background image class, if any
			clearOnSubmit : true  	// clears default text on submit
		};
	
		// if any options are passed, overwrite defaults
		// @note NEW in 1.4: if a string is passed instead of an options object it is used as the hint
		if(options && typeof options == 'object'){
			$.extend(settings, options);
		}else{
			settings.hint = options;
		}
	
		return this.each(function (){
			// cache 'this'
			var container = $(this);
			// get predefined text to be used as filler when blurred
			// @note NEW in 1.4: if a hint is manually specified, it overrides the 'source' option
			var text = settings.hint || container.attr(settings.source);
			// if we have some text to work with proceed
			if (text){ 
				// on blur, set value to pre-defined text if blank
				container.blur(function (){
					if (container.val() == ''){
						container.val(text).addClass(settings.blurClass);
					}
				})
				
				// on focus, set value to blank if filled with pre-defined text
				.focus(function (){
					if (container.val() == text){
						container.val('').removeClass(settings.blurClass);
					}
				});
				
				// clear the pre-defined text when form is submitted
				if(settings.clearOnSubmit){
				  container.parents('form:first').submit(function(){
					  if (container.hasClass(settings.blurClass)){
						  container.val('');
					  }
				  });
				}
				// if a background image class is specified apply it
				if(settings.iconClass){
					container.addClass(settings.iconClass);
				}
				
				// initialize all inputs to blurred state
				container.blur();
			}
		});
	};
})(jQuery);
