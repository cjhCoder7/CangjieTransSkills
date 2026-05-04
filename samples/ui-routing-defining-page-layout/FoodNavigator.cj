import std.collection.*

class RouteRequest {
    let pageName: String
    let hasFood: Bool
    let food: FoodData

    public init(pageName: String, hasFood: Bool, food: FoodData) {
        this.pageName = pageName
        this.hasFood = hasFood
        this.food = food
    }
}

func makeHomeRoute(): RouteRequest {
    RouteRequest(pageName: "FoodCategoryListPage", hasFood: false, food: emptyFoodData())
}

func makeFoodDetailRoute(food: FoodData): RouteRequest {
    RouteRequest(pageName: "FoodDetailPage", hasFood: true, food: food)
}

interface PageRouter {
    func push(request: RouteRequest): Unit
    func back(): Unit
    func current(): RouteRequest
    func historySize(): Int64
}

class MemoryPageRouter <: PageRouter {
    private let history = ArrayList<RouteRequest>()
    private var currentIndex: Int64 = 0

    public init() {
        history.append(makeHomeRoute())
    }

    public func push(request: RouteRequest): Unit {
        history.append(request)
        currentIndex = history.size - 1
    }

    public func back(): Unit {
        if (currentIndex > 0) {
            currentIndex = currentIndex - 1
        }
    }

    public func current(): RouteRequest {
        history[currentIndex]
    }

    public func historySize(): Int64 {
        history.size
    }
}

class SpyPageRouter <: PageRouter {
    private let history = ArrayList<RouteRequest>()
    private let pushedPages = ArrayList<String>()
    private var currentIndex: Int64 = 0

    public init() {
        history.append(makeHomeRoute())
    }

    public func push(request: RouteRequest): Unit {
        history.append(request)
        pushedPages.append(request.pageName)
        currentIndex = history.size - 1
    }

    public func back(): Unit {
        if (currentIndex > 0) {
            currentIndex = currentIndex - 1
        }
    }

    public func current(): RouteRequest {
        history[currentIndex]
    }

    public func historySize(): Int64 {
        history.size
    }

    public func lastPushedPage(): String {
        if (pushedPages.size == 0) {
            ""
        } else {
            pushedPages[pushedPages.size - 1]
        }
    }
}
