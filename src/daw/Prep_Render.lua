--[[
Loop through all ranges in each project (except for mixer project) and IF there
is no asterix (*) at the beginning of the range name, set the render matrix to
master track and then add an asterix to the beginning of the name.  If there is
an asterix (*) at the beginning of the range name, then remove from the render
matrix.

At the very end, we will render out the render matrix and only export the ranges
that haven't been rendered yet.
]]

function prep_render()
  for i_project=1, 100, 1 do
    local project = reaper.EnumProjects(i_project)
    
    if not project then break end
  
    for i_region=0, 100, 1 do
      local isrgn       = 0
      local region_idx  = 0
      local is_render   = true
      retval, isrgn, pos, rgnend, name, region_idx, color = reaper.EnumProjectMarkers3(project, i_region)
      
      if name:sub(1,1) == "*" then is_render = false end
      if region_idx == 0 then break end
      if not isrgn then goto continue end
      
      if is_render then
        reaper.SetRegionRenderMatrix(project, region_idx, reaper.GetMasterTrack(project), 1)
      else
        reaper.SetRegionRenderMatrix(project, region_idx, reaper.GetMasterTrack(project), -1)
      end
      
      for i_track=0, 100, 1 do
        local track = reaper.GetTrack(project, i_track)
        
        if not track then break end
        
        if is_render then
          reaper.SetRegionRenderMatrix(project, region_idx, track, 1)
        else
          reaper.SetRegionRenderMatrix(project, region_idx, track, -1)
        end
        
        if i_track == 100 then reaper.ShowConsoleMsg("REACHED MAX i_track\n") end
      end
  
      if is_render then
        reaper.SetProjectMarker3(project, region_idx, true, pos, rgnend, "*" .. name, color)
      end
      
      ::continue::
      
      if i_region == 100 then reaper.ShowConsoleMsg("REACHED MAX i_region\n") end
    end
  
    if i_project == 100 then reaper.ShowConsoleMsg("REACHED MAX i_project\n") end
  end
end

prep_render()
