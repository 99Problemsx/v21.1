 #===============================================================================
class PokemonPokedexInfo_Scene
  def pbStartScene(dexlist, index, region)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @dexlist = dexlist
    @index   = index
    @region  = region
    @page = 1
    @show_battled_count = false
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/UI/Pokedex/icon_types"))
    @sprites = {}
    # CHANGED: Defines the Scrolling Background, as well as the overlay on top of it    
    @sprites["background"] = ScrollingSprite.new(@viewport)
    @sprites["background"].speed = 1
    @sprites["infoverlay"] = IconSprite.new(0,0,@viewport)
    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::CENTER)
    # CHANGED: Changes the position of the Pokémon in the Entry Page
    @sprites["infosprite"].x = 98
    @sprites["infosprite"].y = 112
    @mapdata = GameData::TownMap.get(@region)
    mappos = $game_map.metadata&.town_map_position
    if @region < 0                                 # Use player's current region
      @region = (mappos) ? mappos[0] : 0                      # Region 0 default
    end
    @sprites["areamap"] = IconSprite.new(0, 0, @viewport)
    @sprites["areamap"].setBitmap("Graphics/UI/Town Map/#{@mapdata.filename}")
    @sprites["areamap"].x += (Graphics.width - @sprites["areamap"].bitmap.width) / 2
    # CHANGED: Y offset
    @sprites["areamap"].y += (Graphics.height + 16 - @sprites["areamap"].bitmap.height) / 2
    Settings::REGION_MAP_EXTRAS.each do |hidden|
      next if hidden[0] != @region || hidden[1] <= 0 || !$game_switches[hidden[1]]
      pbDrawImagePositions(
        @sprites["areamap"].bitmap,
        [["Graphics/UI/#{hidden[4]}",
          hidden[2] * PokemonRegionMap_Scene::SQUARE_WIDTH,
          hidden[3] * PokemonRegionMap_Scene::SQUARE_HEIGHT]]
      )
    end
    @sprites["areahighlight"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["areaoverlay"] = IconSprite.new(0, 0, @viewport)
    @sprites["areaoverlay"].setBitmap("Graphics/UI/Pokedex/overlay_area")
    @sprites["formfront"] = PokemonSprite.new(@viewport)
    @sprites["formfront"].setOffset(PictureOrigin::CENTER)
    # CHANGED: Changes the X and Y position of the front sprite of the Pokémon in the Forms Page
    @sprites["formfront"].x = 382
    @sprites["formfront"].y = 240
    @sprites["formback"] = PokemonSprite.new(@viewport)
    @sprites["formback"].setOffset(PictureOrigin::CENTER)
    # CHANGED: Changes the X position of the back sprite of the Pokémon in the Forms Page
    @sprites["formback"].x = 124   # y is set below as it depends on metrics
    @sprites["formicon"] = PokemonSpeciesIconSprite.new(nil, @viewport)
    @sprites["formicon"].setOffset(PictureOrigin::CENTER)
    # CHANGED: Changes the X and Y position of the icon sprite of the Pokémon in the Forms Page
    @sprites["formicon"].x = 64
    @sprites["formicon"].y = 112
    # CHANGED: Changes the Y position of the Up Arrow sprite of the Pokémon in the Forms Page
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/UI/up_arrow", 8, 28, 40, 2, @viewport)
    @sprites["uparrow"].x = 242
    @sprites["uparrow"].y = 40
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    # CHANGED: Changes the Y position of the Down Arrow sprite of the Pokémon in the Forms Page
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/UI/down_arrow", 8, 28, 40, 2, @viewport)
    @sprites["downarrow"].x = 242
    @sprites["downarrow"].y = 128
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFontBW(@sprites["overlay"].bitmap)
    pbUpdateDummyPokemon
    @available = pbGetAvailableForms
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartSceneBrief(species)  # For standalone access, shows first page only
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    dexnum = 0
    dexnumshift = false
    if $player.pokedex.unlocked?(-1)   # National Dex is unlocked
      species_data = GameData::Species.try_get(species)
      if species_data
        nationalDexList = [:NONE]
        GameData::Species.each_species { |s| nationalDexList.push(s.species) }
        dexnum = nationalDexList.index(species_data.species) || 0
        dexnumshift = true if dexnum > 0 && Settings::DEXES_WITH_OFFSETS.include?(-1)
      end
    else
      ($player.pokedex.dexes_count - 1).times do |i|   # Regional Dexes
        next if !$player.pokedex.unlocked?(i)
        num = pbGetRegionalNumber(i, species)
        next if num <= 0
        dexnum = num
        dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(i)
        break
      end
    end
    @dexlist = [[species, "", 0, 0, dexnum, dexnumshift]]
    @index   = 0
    @page = 1
    @brief = true
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/UI/Pokedex/icon_types"))
    @sprites = {}
    # CHANGED: Defines the Scrolling Background of the Entry Scene when capturing a Wild Pokémon, as well as the overlay on top of it
    # and the capture bar
    @sprites["background"] = ScrollingSprite.new(@viewport)
    @sprites["background"].speed = 1
    @sprites["infoverlay"] = IconSprite.new(0,0,@viewport)
    @sprites["capturebar"] = IconSprite.new(0,0,@viewport)

    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::CENTER)
    # CHANGED: Changes the X position of the front sprite of the Pokémon in the Entry Scene when capturing a Wild Pokémon
    @sprites["infosprite"].x = 98
    @sprites["infosprite"].y = 136
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFontBW(@sprites["overlay"].bitmap)
    pbUpdateDummyPokemon
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @viewport.dispose
  end

  def pbUpdate
    if @page == 2
      intensity_time = System.uptime % 1.0   # 1 second per glow
      if intensity_time >= 0.5
        intensity = lerp(64, 256 + 64, 0.5, intensity_time - 0.5)
      else
        intensity = lerp(256 + 64, 64, 0.5, intensity_time)
      end
      @sprites["areahighlight"].opacity = intensity
    end
    pbUpdateSpriteHash(@sprites)
  end

  alias bw_style_pbUpdateDummyPokemon pbUpdateDummyPokemon unless method_defined?(:bw_style_pbUpdateDummyPokemon)
  def pbUpdateDummyPokemon
    bw_style_pbUpdateDummyPokemon
    @species = @dexlist[@index][:species]
    @gender, @form, _shiny = $player.pokedex.last_form_seen(@species)
    @shiny = false
    metrics_data = GameData::SpeciesMetrics.get_species_form(@species, @form)
    @sprites["infosprite"].setSpeciesBitmap(@species, @gender, @form, @shiny)
    @sprites["formfront"]&.setSpeciesBitmap(@species, @gender, @form, @shiny)
    if @sprites["formback"]
      @sprites["formback"].setSpeciesBitmap(@species, @gender, @form, @shiny, false, true)
      @sprites["formback"].y = 226
      @sprites["formback"].y += metrics_data.back_sprite[1] * 2
    end
    @sprites["formicon"]&.pbSetParams(@species, @gender, @form, @shiny)
  end

  def pbGetAvailableForms
    ret = []
    multiple_forms = false
    gender_differences = (GameData::Species.front_sprite_filename(@species, 0) == GameData::Species.front_sprite_filename(@species, 0, 1))
    # Find all genders/forms of @species that have been seen
    GameData::Species.each do |sp|
      next if sp.species != @species
      next if sp.form != 0 && (!sp.real_form_name || sp.real_form_name.empty?)
      next if sp.pokedex_form != sp.form
      multiple_forms = true if sp.form > 0
      if sp.single_gendered?
        real_gender = (sp.gender_ratio == :AlwaysFemale) ? 1 : 0
        next if !$player.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
        real_gender = 2 if sp.gender_ratio == :Genderless
        ret.push([sp.form_name, real_gender, sp.form])
      elsif sp.form == 0 && !gender_differences
        2.times do |real_gndr|
          next if !$player.pokedex.seen_form?(@species, real_gndr, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
          ret.push([sp.form_name || _INTL("One Form"), 0, sp.form])
          break
        end
      else   # Both male and female
        2.times do |real_gndr|
          next if !$player.pokedex.seen_form?(@species, real_gndr, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
          ret.push([sp.form_name, real_gndr, sp.form])
          break if sp.form_name && !sp.form_name.empty?   # Only show 1 entry for each non-0 form
        end
      end
    end
    # Sort all entries
    ret.sort! { |a, b| (a[2] == b[2]) ? a[1] <=> b[1] : a[2] <=> b[2] }
    # Create form names for entries if they don't already exist
    ret.each do |entry|
      if entry[0]   # Alternate forms, and form 0 if no gender differences
        entry[0] = "" if !multiple_forms && !gender_differences
      else   # Necessarily applies only to form 0
        case entry[1]
        when 0 then entry[0] = _INTL("Male")
        when 1 then entry[0] = _INTL("Female")
        else
          entry[0] = (multiple_forms) ? _INTL("One Form") : _INTL("Genderless")
        end
      end
      entry[1] = 0 if entry[1] == 2   # Genderless entries are treated as male
    end
    return ret
  end

  def drawPage(page)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    # Make certain sprites visible
    @sprites["infosprite"].visible    = (@page == 1)
    @sprites["areamap"].visible       = (@page == 2) if @sprites["areamap"]
    @sprites["areahighlight"].visible = (@page == 2) if @sprites["areahighlight"]
    @sprites["areaoverlay"].visible   = (@page == 2) if @sprites["areaoverlay"]
    @sprites["formfront"].visible     = (@page == 3) if @sprites["formfront"]
    @sprites["formback"].visible      = (@page == 3) if @sprites["formback"]
    @sprites["formicon"].visible      = (@page == 3) if @sprites["formicon"]
    # Draw page-specific information
    case page
    when 1 then drawPageInfo
    when 2 then drawPageArea
    when 3 then drawPageForms
    end
  end

  def drawPageInfo
    # Sets the Scrolling Background of the Entry Page, as well as the overlay on top of it
    @sprites["background"].setBitmap(_INTL("Graphics/UI/Pokedex/bg_info"))
    @sprites["infoverlay"].setBitmap(_INTL("Graphics/UI/Pokedex/info_overlay"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(82, 82, 90)
    shadow = Color.new(165, 165, 173)
    imagepos = []
    if @brief
      # Sets the Scrolling Background of the Entry Scene when capturing a wild Pokémon, as well as the overlay on top of it
      @sprites["background"].setBitmap(_INTL("Graphics/UI/Pokedex/bg_capture"))
      @sprites["infoverlay"].setBitmap(_INTL("Graphics/UI/Pokedex/capture_overlay"))
      @sprites["capturebar"].setBitmap(_INTL("Graphics/UI/Pokedex/overlay_info"))
    end
    species_data = GameData::Species.get_species_form(@species, @form)
    # Write various bits of text
    indexText = "???"
    if @dexlist[@index][:number] > 0
      indexNumber = @dexlist[@index][:number]
      indexNumber -= 1 if @dexlist[@index][:shift]
      indexText = sprintf("%03d", indexNumber)
    end
    # This bit of the code woudn't have been possible without the help of NettoHikari.
    # He helped me to set the Sprites and Texts differently, depending on if the 
    # Pokédex Entry Scene is playing, when the payer is capturing a Wild Pokémon, 
    # or if the player is seeing the "normal" Dex Entry page on the Pokédex.
    #
    # Basically, this next lines changes the position of various text 
    # (height, weight, the Name's Species, etc), depending on if the 
    # Pokédex Entry Scene is playing, when the player is capturing a Wild Pokémon, 
    # or if the player is seeing the "normal" Dex Entry page on the Pokédex.
    if @brief
      textpos = [
        [_INTL("Pokémon Registration Complete"), 82, -2, 0, Color.new(255, 255, 255), Color.new(165, 165, 173)],
        [_INTL("{1}{2} {3}", indexText, " ", species_data.name),
            272, 54, 0, Color.new(82, 82, 90), Color.new(165, 165, 173)],
        [_INTL("Height"), 288, 170, 0, base, shadow],
        [_INTL("Weight"), 288, 200, 0, base, shadow]
      ]
    else
      textpos = [
        [_INTL("{1}{2} {3}", indexText, " ", species_data.name),
            272, 16, 0, Color.new(82, 82, 90), Color.new(165, 165, 173)],
        [_INTL("Height"), 288, 132, 0, base, shadow],
        [_INTL("Weight"), 288, 162, 0, base, shadow]
      ]
    end
    if $player.owned?(@species)
      # Write the category. Changed
      if @brief
        textpos.push([_INTL("{1} Pokémon", species_data.category), 376, 90, 2, base, shadow])
      else
        textpos.push([_INTL("{1} Pokémon", species_data.category), 376, 52, 2, base, shadow])
      end
      # Write the height and weight. Changed
      height = species_data.height
      weight = species_data.weight
      if System.user_language[3..4] == "US"   # If the user is in the United States
        inches = (height / 0.254).round
        pounds = (weight / 0.45359).round
        if @brief
          textpos.push([_ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12), 490, 170, 1, base, shadow])
          textpos.push([_ISPRINTF("{1:4.1f} lbs.", pounds / 10.0), 490, 200, 1, base, shadow])
        else
          textpos.push([_ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12), 490, 132, 1, base, shadow])
          textpos.push([_ISPRINTF("{1:4.1f} lbs.", pounds / 10.0), 490, 162, 1, base, shadow])
        end
      else
	  	  if @brief
          textpos.push([_ISPRINTF("{1:.1f} m", height / 10.0), 490, 170, 1, base, shadow])
          textpos.push([_ISPRINTF("{1:.1f} kg", weight / 10.0), 490, 200, 1, base, shadow])
			  else
		      textpos.push([_ISPRINTF("{1:.1f} m", height / 10.0), 490, 132, 1, base, shadow])
          textpos.push([_ISPRINTF("{1:.1f} kg", weight / 10.0), 490, 162, 1, base, shadow])
			  end
      end
      # Draw the Pokédex entry text. Changed
	    base   = Color.new(255,255,255)
      shadow = Color.new(165,165,173)
      drawTextEx(overlay, 38, @brief ? 250 : 212, Graphics.width - (40 * 2), 4,   # overlay, x, y, width, num lines
                species_data.pokedex_entry, base, shadow)
      # Draw the footprint. Changed
      footprintfile = GameData::Species.footprint_filename(@species, @form)
      if footprintfile
        footprint = RPG::Cache.load_bitmap("",footprintfile)
        overlay.blt(224, @brief ? 150 : 112, footprint, footprint.rect)
        footprint.dispose
      end
      # Show the owned icon. Changed
      imagepos.push(["Graphics/UI/Pokedex/icon_own", 210, @brief ? 57 : 19])
      # Draw the type icon(s). Changed
      species_data.types.each_with_index do |type, i|
        type_number = GameData::Type.get(type).icon_position
        type_rect = Rect.new(0, type_number * 32, 96, 32)
        overlay.blt(286 + (80 * i), @brief ? 132 : 94, @typebitmap.bitmap, type_rect)
      end
    else
      # This bit of the code below is simply the Entry Page when you have seen the Pokémon, but didn't capture it yet.
      # Write the category. Changed
      textpos.push([_INTL("????? Pokémon"), 274, 50, 0, base, shadow])
      # Write the height and weight. Changed
      if System.user_language[3..4] == "US"   # If the user is in the United States
        textpos.push([_INTL("???'??\""), 490, 136, 1, base, shadow])
        textpos.push([_INTL("????.? lbs."), 488, 170, 1, base, shadow])
      else
        textpos.push([_INTL("????.? m"), 488, 132, 1, base, shadow])
        textpos.push([_INTL("????.? kg"), 488, 162, 1, base, shadow])
      end
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
  end

  def drawPageArea
    # CHANGED: Sets the Scrolling Background of the Area Page, as well as the overlay on top of it
    @sprites["background"].setBitmap(_INTL("Graphics/UI/Pokedex/bg_area"))
    @sprites["infoverlay"].setBitmap(_INTL("Graphics/UI/Pokedex/map_overlay"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    @sprites["areahighlight"].bitmap.clear
    # Get all points to be shown as places where @species can be encountered
    points = pbGetEncounterPoints
    # Draw coloured squares on each point of the Town Map with a nest
    pointcolor   = Color.new(0, 248, 248)
    pointcolorhl = Color.new(192, 248, 248)
    town_map_width = 1 + PokemonRegionMap_Scene::RIGHT - PokemonRegionMap_Scene::LEFT
    sqwidth = PokemonRegionMap_Scene::SQUARE_WIDTH
    sqheight = PokemonRegionMap_Scene::SQUARE_HEIGHT
    points.length.times do |j|
      next if !points[j]
      x = (j % town_map_width) * sqwidth
      x += (Graphics.width - @sprites["areamap"].bitmap.width) / 2
      y = (j / town_map_width) * sqheight
      # CHANGED: Y offset
      y += (Graphics.height + 16 - @sprites["areamap"].bitmap.height) / 2
      @sprites["areahighlight"].bitmap.fill_rect(x, y, sqwidth, sqheight, pointcolor)
      if j - town_map_width < 0 || !points[j - town_map_width]
        @sprites["areahighlight"].bitmap.fill_rect(x, y - 2, sqwidth, 2, pointcolorhl)
      end
      if j + town_map_width >= points.length || !points[j + town_map_width]
        @sprites["areahighlight"].bitmap.fill_rect(x, y + sqheight, sqwidth, 2, pointcolorhl)
      end
      if j % town_map_width == 0 || !points[j - 1]
        @sprites["areahighlight"].bitmap.fill_rect(x - 2, y, 2, sqheight, pointcolorhl)
      end
      if (j + 1) % town_map_width == 0 || !points[j + 1]
        @sprites["areahighlight"].bitmap.fill_rect(x + sqwidth, y, 2, sqheight, pointcolorhl)
      end
    end
    # Set the text
    # Changes the color of the text, to the one used in BW
    base   = Color.new(255,255,255)
    shadow = Color.new(165,165,173)
    textpos = []
    if points.length == 0
      pbDrawImagePositions(
        overlay,
        [[sprintf("Graphics/UI/Pokedex/overlay_areanone"), 108, 148]] # CHANGED: Y value
      )
      textpos.push([_INTL("Area unknown"), Graphics.width / 2, 146, 2, base, shadow]) # CHANGED: Y value
    end
    # CHANGED: Minor changes to the color of the text, to mimic the one used in BW
    textpos.push([@mapdata.name, 414, 50, :center, base, shadow])
    # CHANGED: Minor changes to the color of the text, to mimic the one used in BW
    textpos.push([_INTL("{1}'s area", GameData::Species.get(@species).name),
                  Graphics.width / 1.4, 0, 2, Color.new(255,255,255), Color.new(115,115,115)])
    pbDrawTextPositions(overlay, textpos)
  end

  def drawPageForms
    # CHANGED: Sets the Scrolling Background of the Forms Page, as well as the overlay on top of it
    @sprites["background"].setBitmap(_INTL("Graphics/UI/Pokedex/bg_forms"))
    @sprites["infoverlay"].setBitmap(_INTL("Graphics/UI/Pokedex/forms_overlay"))
    overlay = @sprites["overlay"].bitmap
    # CHANGED: Changes the color of the text, to the one used in BW
    base   = Color.new(255,255,255)
    shadow = Color.new(165,165,173)
    # Write species and form name
    formname = ""
    for i in @available
      if i[1]==@gender && i[2]==@form
        formname = i[0]; break
      end
    end
    # CHANGED: Change text attributes
    textpos = [
	    [_INTL("Forms"),58,0,0,Color.new(255,255,255),Color.new(115,115,115)],
      [GameData::Species.get(@species).name,Graphics.width/2,Graphics.height-316,2,base,shadow],
      [formname,Graphics.width/2,Graphics.height-280,2,base,shadow],
    ]
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
  end
end
