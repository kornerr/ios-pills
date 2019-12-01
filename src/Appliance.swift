
enum ApplianceType: String, CaseIterable
{
    case kettle = "Type.Kettle"
    case multicooker = "Type.Multicooker"
    case coffeeMachine = "Type.CoffeeMachine"
}

func idToApplianceType(_ id: Int) -> ApplianceType?
{
    let items = ApplianceType.allCases
    if id < items.count
    {
        return items[id]
    }

    return nil
}

func applianceTypeToId(_ type: ApplianceType) -> Int?
{
    let items = ApplianceType.allCases
    for (id, item) in items.enumerated()
    {
        if item == type
        {
            return id
        }
    }
    
    return nil
}

struct Appliance
{
    var type: ApplianceType
    var state: Bool
}

