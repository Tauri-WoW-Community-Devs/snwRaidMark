local function SetWMSequence(sequence)
  if type(sequence) ~= "table" or #sequence == 0 then return end

  sRMAdvance:Execute([[seqtable = newtable()]])

  for i,v in ipairs(sequence) do
    sRMAdvance:Execute(([[seqtable[%s] = %s]]):format(i,v))
  end

  sRMAdvance:SetAttribute("wmphase",0)
  sRMPlaceMark:SetAttribute("macrotext",nil)
end

local function p(str)
	if (str) then
		prefix = "|cffff8359sRM: |r"
		suffix = ""
		print(prefix..str..suffix)
	end
end

do
  local f = sRMClick or CreateFrame("button","sRMClick",nil,"SecureActionButtonTemplate")
  f:RegisterForClicks("AnyDown")
  f:SetAttribute("type","macro")
  f:SetAttribute("macrotext1","/click sRMAdvance\10/click sRMPlaceMark")
  f:SetAttribute("macrotext","/click sRMAdvance clear\10/click sRMPlaceMark")
end

do
  local f = sRMPlaceMark or CreateFrame("button","sRMPlaceMark",nil,"SecureActionButtonTemplate")
  f:RegisterForClicks("AnyDown")
  f:SetAttribute("type","macro")
end

do
  local f = sRMAdvance or CreateFrame("button","sRMAdvance",nil,"SecureHandlerClickTemplate")
  f:RegisterForClicks("AnyDown")
  f:SetFrameRef("sRMPlaceMark",sRMPlaceMark)
  f:SetAttribute("_onclick",[[
        local execFrame = self:GetFrameRef("sRMPlaceMark")
        if button == "clear" then
            self:SetAttribute("wmphase",0)
            execFrame:SetAttribute("macrotext","/cwm all")
        else

          local phase = self:GetAttribute("wmphase") + 1
          self:SetAttribute("wmphase",phase)

          local nextmarker = seqtable[phase]
          local macrotext = nil
          if nextmarker then
            macrotext = "/wm "..nextmarker
          else
            macrotext = "/cwm all"
            self:SetAttribute("wmphase", 0)
          end
          execFrame:SetAttribute("macrotext",macrotext)
        end
    ]])

  SetWMSequence({1,2,3})
end

local function help()
  p("Syntax:")
  p("/rminit 1 3 2 5 4")
  p("numbers indicate the corresponding worldmark")
  p("starting from the beginning, after cycled through")
  p("------")
  p("to use it on a single button")
  p("create a macro with `/click sRMClick`")
end

do
  SLASH_RM_TOGGLE_INIT1 = "/srminit"
  SLASH_RM_TOGGLE_HELP1 = "/srmhelp"
  SlashCmdList.RM_TOGGLE_INIT = function(msg)
    if msg == "" then
      help()
      return
    end
    if InCombatLockdown() then return end
    local seq = {}
    msg:gsub("(%d+)",function(a)tinsert(seq,a)end)
    p("worldmarks " .. msg .. " set.")
    SetWMSequence(seq)
  end

  SlashCmdList.RM_TOGGLE_HELP = help
end