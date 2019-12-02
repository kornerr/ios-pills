import CoreData

class PillsCache
{
    let ENTITY_NAME = "PillItem"

    var context: NSManagedObjectContext

    init(context: NSManagedObjectContext)
    {
        self.context = context
    }

    var items: [Pill]
    {
        get
        {
            return self.loadItems()
        }
        set
        {
            self.saveItems(newValue)
        }
    }

    private func LOG(_ message: String)
    {
        NSLog("PillsCache \(message)")
    }

    private func addItem(_ item: Pill)
    {
        guard
            let entity =
                NSEntityDescription.entity(
                    forEntityName: self.ENTITY_NAME,
                    in: context
                )
        else
        {
            LOG("ERROR Could not add a pill to cache because entity is invalid")
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

    private func loadItems() -> [Pill]
    {
        var items = [Pill]()

        let request =
            NSFetchRequest<NSManagedObject>(entityName: self.ENTITY_NAME)
        do
        {
            let objs = try self.context.fetch(request)
            for obj in objs
            {
                if let item = self.objToItem(obj)
                {
                    items.append(item)
                }
            }
        }
        catch
        {
            LOG("ERROR Could not fetch items: '\(error)'")
        }

        return items
    }

    private func objToItem(_ obj: NSManagedObject) -> Pill?
    {
        guard
            let id = obj.value(forKeyPath: "id") as? Int,
            let name = obj.value(forKeyPath: "name") as? String,
            let imgURLString = obj.value(forKeyPath: "imgURLString") as? String,
            let desc = obj.value(forKeyPath: "desc") as? String,
            let dose = obj.value(forKeyPath: "dose") as? String
        else
        {
            return nil
        }

        return
            Pill(
                id: id,
                name: name,
                imgURLString: imgURLString,
                desc: desc,
                dose: dose
            )
    }

    private func save()
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

    private func clear()
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PillItem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do
        {
            try self.context.execute(deleteRequest)
        }
        catch
        {
            LOG("ERROR Could not clear the cache: '\(error)'")
        }
    }

    private func saveItems(_ items: [Pill])
    {
        self.clear()
        for item in items
        {
            self.addItem(item)
        }
        self.save()
    }

}
