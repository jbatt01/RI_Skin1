// JavaScript Document
function writeFlashContent(){
	document.write('<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0" id="player" width="100%" height="100%" align="middle">');
	document.write('<param name="allowScriptAccess" value="sameDomain" />');
	document.write("<param name=menu value='false'/>");
	document.write('<param name="movie" value="player.swf" /><param name="quality" value="high" /><param name="bgcolor" value="#ffffff" /><embed src="player.swf" quality="high" bgcolor="#ffffff" width="100%" height="100%" name="player" align="middle" menu="false" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" wmode="opaque"/>');
	document.write('</object>');
}