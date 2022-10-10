-- markeridx, regionidx = reaper.GetLastMarkerAndCurRegion(nil, reaper.GetCursorPosition())
-- reaper.GetSet_LoopTimeRange(true, true, 0, 32, false)
-- a, a, a, a, mkr_name, a = reaper.EnumProjectMarkers(markeridx)
-- a, a, a, a, rgn_name, a = reaper.EnumProjectMarkers(regionidx)
-- reaper.ShowConsoleMsg("markeridx: " .. mkr_name .. ", num: " .. markeridx .. "\n")
-- reaper.ShowConsoleMsg("regionidx: " .. rgn_name .. ", num: " .. regionidx ..  "\n")
-- reaper.GoToRegion(0, 2, false)


if reaper.HasExtState("mixer_switch","last_project") then
  -- returning back from mixer view
  reaper.SelectProjectInstance( reaper.EnumProjects(reaper.GetExtState("mixer_switch", "last_project")) )
  reaper.Main_OnCommand(40455, 0)
  reaper.DeleteExtState("mixer_switch", "last_project", true)
else
  -- switching to mixer view
  
  -- need to find current tab number
  local i, project = 0, reaper.EnumProjects(-1, '')
  while i<100 do
    if reaper.EnumProjects(i, '') == project then
      break
    else
     i = i + 1
    end
  end
  
  if i<100 then
    reaper.SetExtState("mixer_switch", "last_project", i, true)
    reaper.SelectProjectInstance(reaper.EnumProjects(0))
    reaper.Main_OnCommand(40454, 0)
  end
end
