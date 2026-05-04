import std.unittest.*
import std.unittest.testmacro.*

@Test
public class UiRoutingPageTests {
    @TestCase
    public func defaultModeIsGrid(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        assertEqual("默认应进入网格视图", "", "grid", page.currentViewMode())
        assertEqual("默认分类应为 All", "", "All", page.selectedCategory())
    }

    @TestCase
    public func toggleViewChangesListMode(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        page.toggleView()
        assertEqual("切换后应进入列表视图", "", "list", page.currentViewMode())
    }

    @TestCase
    public func vegetableFilterReturnsOnlyVegetables(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        page.selectCategory("Vegetable")
        let vegetables = page.visibleFoodsForCurrentCategory()
        assertEqual("Vegetable 分类条目数量应正确", "", 4, vegetables.size)
        assertEqual("第一项应为 Tomato", "", "Tomato", vegetables[0].name)
        assertEqual("第二项应为 Cucumber", "", "Cucumber", vegetables[1].name)
        assertEqual("第三项应为 Onion", "", "Onion", vegetables[2].name)
        assertEqual("第四项应为 Mushroom", "", "Mushroom", vegetables[3].name)
    }

    @TestCase
    public func gridRowCountShouldMatchTwoColumnLayout(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        page.selectCategory("All")
        assertEqual("12 个元素在双列网格中应形成 6 行", "", 6, page.gridRowCount())
    }

    @TestCase
    public func openFoodDetailShouldPushRouterRequest(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        let firstFood = page.visibleFoods("All")[0]
        page.openFoodDetail(firstFood)
        assertEqual("应跳转到详情页", "", "FoodDetailPage", router.lastPushedPage())
        assertEqual("路由历史应增加到 2", "", 2, router.historySize())
        assertEqual("当前路由中应带有 Tomato", "", "Tomato", router.current().food.name)
    }

    @TestCase
    public func detailPageShouldReadFoodFromRouter(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        let targetFood = page.visibleFoods("All")[3]
        page.openFoodDetail(targetFood)
        let detailPage = FoodDetailPage(router: router)
        detailPage.aboutToAppear()
        assertEqual("详情页应加载 Blueberry", "", "Blueberry", detailPage.currentFoodName())
    }

    @TestCase
    public func detailPageBackShouldReturnToHome(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        let targetFood = page.visibleFoods("All")[1]
        page.openFoodDetail(targetFood)
        let detailPage = FoodDetailPage(router: router)
        detailPage.aboutToAppear()
        detailPage.tapBack()
        assertEqual("返回后当前页面应为列表页", "", "FoodCategoryListPage", router.current().pageName)
    }
}
