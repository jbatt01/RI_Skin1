//Size all the elements before loading data.
var contentW:Number = playerMain_mc.presentSizeW;
var contentH:Number = playerMain_mc.presentSizeH;

//Size elements on stage
steps_back_mc._height = contentH - 30;
title_bkgnd_mc._width = contentW+3;
step_title_back_mc._width = contentW - 50;
stepNav_mc._x = contentW - 100;
stepTitle_txt._width = contentW - 280;
taskTitle_txt._width = contentW -15;
enlarge_mc.setSize(contentW - 390,contentH - 280);
enlarge_mc.move(280,enlarge_mc.y);
stepDescription_ta.setSize(contentW - 180,contentH - (enlarge_mc.y + enlarge_mc.height + 30));
stepDescription_ta.move(stepDescription_ta.x,enlarge_mc.y + enlarge_mc.height + 15);
s_mask_mc._width = contentW;
s_mask_mc._height = contentH;

var titleBarColor:String = playerMain_mc.currentPage_xmlnode.attributes.titleBarColor;

if (titleBarColor.indexOf("0x") == -1)
{
	titleBarColor = "0x003366";
}

var satPct:Number = 50;
barColor = new Color(title_bkgnd_mc.title_back_mc);
barColor.setTint(playerMain_mc.convertHexToR(titleBarColor),playerMain_mc.convertHexToG(titleBarColor),playerMain_mc.convertHexToB(titleBarColor), satPct);

gotoAndStop("load");