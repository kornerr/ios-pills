import CoreData

class PillsCache
{
    var context: NSManagedObjectContext
    var entity: NSEntityDescription?

    init(context: NSManagedObjectContext)
    {
        self.context = context
        self.entity =
            NSEntityDescription.entity(
                forEntityName: "PillItem",
                in: context
            )
    }

    private func LOG(_ message: String)
    {
        NSLog("PillsCache \(message)")
    }

    func addItem(_ item: Pill)
    {
        guard
            let entity = self.entity
        else
        {
            LOG("ERROR Could not cache a pill because entity is invalid")
            return
        }

        let obj =
            NSManagedObject(entity: entity, insertInto: self.context)
        obj.setValue(item.id, forKeyPath: "id")
        obj.setValue(item.name, forKeyPath: "name")
        obj.setValue(item.imgURLString, forKeyPath: "imgURLString")
        obj.setValue(item.desc, forKeyPath: "desc")
	        obj.setValue(item.dose, forKeyPath: "dose")
    }

    func printItems()
    {
        let request = NSFetchRequest<NSManagedObject>(entityName: "PillItem")
        do
        {
            let items = try self.context.fetch(request)
            for item in items
            {
                if
                    let id = item.value(forKeyPath: "id") as? Int,
                    let name = item.value(forKeyPath: "name") as? String,
                    let imgURLString = item.value(forKeyPath: "imgURLString") as? String,
                    let desc = item.value(forKeyPath: "desc") as? String,
                    let dose = item.value(forKeyPath: "dose") as? String
                {
                    let pill =
                        Pill(
                            id: id,
                            name: name,
                            imgURLString: imgURLString,
                            desc: desc,
                            dose: dose
                        )
                    LOG("Item: '\(pill)'")
                }
            }
        }
        catch
        {
            LOG("ERROR Could not fetch items: '\(error)'")
        }
    }

    func save()
    {
        do
        {
            try self.context.save()
        }
        catch
        {
            LOG("ERROR Could not save the cache: '\(error)'")
        }
    }

}
