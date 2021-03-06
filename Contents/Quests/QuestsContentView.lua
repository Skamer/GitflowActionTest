-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Quests.QuestsContentView"               ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
-- Iterator helper for ignoring the children are used for backdrop, and avoiding
-- they are taken as account for their parent height
IterateFrameChildren = Utils.IterateFrameChildren
-- ========================================================================= --
ResetStyles           = Utils.ResetStyles
ValidateFlags         = System.Toolset.validateflags
-- ========================================================================= --
__Recyclable__ "SylingTracker_QuestsContentView%d"
class "QuestsContentView" (function(_ENV)
  inherit "ContentView"

  __Flags__()
  enum "Flags" {
    NONE = 0,
    HAS_QUESTS = 1,
    HAS_CATEGORIES = 2,
  }
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    local questsData = data.quests 

    -- Determines the flags
    local flags = Flags.NONE 
    if questsData then 
      flags = Flags.HAS_CATEGORIES
    end
    
    if flags ~= self.Flags then 
      ResetStyles(self)

      -- are there quests 
      if ValidateFlags(Flags.HAS_QUESTS, flags) then 
        self:AcquireQuests()
      else
        self:ReleaseQuests()
      end

      -- are there categories 
      if ValidateFlags(Flags.HAS_CATEGORIES, flags) then 
        self:AcquireCategories()
      else 
        self:ReleaseCategories()
      end

      -- Styling stuff 
      if flags ~= Flags.NONE then 
        local styles = self.FlagsStyles and self.FlagsStyles[flags]
        if styles then 
          Style[self] = styles
        end
      end
    end


    if questsData then
      if self.ShowCategories then 
        local categories = self:AcquireCategories()
        categories:UpdateView(questsData)
      else 
        local quests = self:AcquireQuests()
        quests:UpdateView(questsData)
      end
    end

    self.Flags = flags
  end

  function AcquireQuests(self)
    local content = self:GetChild("Content")
    local quests = content:GetChild("Quests")
    if not quests then 
      quests = QuestListView.Acquire()

      -- We need to keep the old name when we'll release it
      self.__PreviousQuestsName = quests:GetName()

      quests:SetParent(content)
      quests:SetName("Quests")
      quests:InstantApplyStyle()

      -- Register the events
      quests.OnSizeChanged = quests.OnSizeChanged + self.OnChildrenSizeChanged

      self:AdjustHeight(true)
    end
    
    return quests
  end

  function ReleaseQuests(self)
    local content = self:GetChild("Content")
    local quests = content:GetChild("Quests")
    if quests then 
      -- Give its old name (generated by the recycle system)
      quests:SetName(self.__PreviousQuestsName)
      self.__PreviousQuestsName = nil

      -- Unregister the events
      quests.OnSizeChanged = quests.OnSizeChanged - self.OnChildrenSizeChanged

      -- It's better to release it after the event has been unregistered for avoiding
      -- useless call
      quests:Release()

      self:AdjustHeight(true)
    end
  end

  function AcquireCategories(self)
    local content = self:GetChild("Content")
    local categories = content:GetChild("Categories")
    if not categories then 
      categories = QuestCategoryListView.Acquire()

      -- We need to keep the old name when we'll release it
      self.__previousQuestsListName = categories:GetName()

      categories:SetParent(content)
      categories:SetName("Categories")
      categories:InstantApplyStyle()

      -- -- It's important to only style it once we have set its parent and its new
      -- -- name 
      -- if self.Quests then 
      --   Style[quests] = self.Quests
      -- end

      -- Register the events
      categories.OnSizeChanged = categories.OnSizeChanged + self.OnChildrenSizeChanged

      self:AdjustHeight(true)
    end
    
    return categories
  end

  function ReleaseCategories(self)
    local content = self:GetChild("Content")
    local categories = content:GetChild("Categories")

    if categories then 
      -- Give its old name (generated by the recycle system)
      categories:SetName(self.__PreviousCategoriesName)
      self.__PreviousCategoriesName = nil

      -- Unregister the events
      categories.OnSizeChanged = categories.OnSizeChanged - self.OnChildrenSizeChanged

      -- It's better to release it after the event has been unregistered for avoiding
      -- useless call
      categories:Release()

      self:AdjustHeight(true)
    end 
  end

  function OnRelease(self)
    -- First, release the children 
    self:ReleaseQuestsList()
    self:ReleaseCategories()

    -- We call the "Parent" OnRelease (see, ContentView)
    super.OnRelease(self)

    self.Flags = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "FlagsStyles" {
    type = Table
  }

  property "Flags" {
    type = QuestsContentView.Flags,
    default = QuestsContentView.Flags.NONE
  }

  property "ShowCategories" {
    type = Boolean,
    default = true
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{}
  function __ctor(self)
    self.OnChildrenSizeChanged = function() self:AdjustHeight(true) end
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [QuestsContentView] = {
    Header = {
      IconBadge = {
        backdropColor = { r = 0, g = 0, b = 0, a = 0},
        Icon = {
          atlas = AtlasType("QuestNormal")
        }
      },

      Label = {
        text = "Quests"
      }
    },
    Content = {
      backdropColor = { r = 1, g = 0, b = 0, a = 1},
      location = {
        Anchor("TOP", 0, -5, "Header", "BOTTOM"),
        Anchor("LEFT", 5, 0),
        Anchor("RIGHT", -5, 0)
      }
    },

    FlagsStyles = {
      [QuestsContentView.Flags.HAS_QUESTS] = {
        Content = {
          Quests = {
            location = {
              Anchor("TOP"),
              Anchor("LEFT"),
              Anchor("RIGHT")
            }
          }
        }
      },

      [QuestsContentView.Flags.HAS_CATEGORIES] = {
        Content = {
          Categories = {
            location = {
              Anchor("TOP"),
              Anchor("LEFT"),
              Anchor("RIGHT")
            }
          }
        }
      }
    }
  }
})
