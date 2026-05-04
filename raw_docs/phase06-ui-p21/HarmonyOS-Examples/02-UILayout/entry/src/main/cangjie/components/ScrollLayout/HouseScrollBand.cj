/**
 * Created on 2025/8/12
 */
package ohos_app_cangjie_entry.components.ScrollLayout


import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import cj_res_entry.app
import std.sync.*
import std.time.*


let gapY: Int64 = 20
let imgHeight: Int64 = 500
let titleHeight: Int64 = 100
let descHeight: Int64 = 600
let totalHeight: Int64 = (imgHeight + gapY * 4 + titleHeight + descHeight)


@Component
public class HouseScrollItem {
    @Prop var title: String
    @Prop var price: Int64
    @Prop var imgSrc: CJResource
    @Prop var desc: String

    func build() {
        Column(gapY.lpx) {
            Image(imgSrc).height(imgHeight.lpx)

            Text("${title} \n$${price} Million").fontSize(36.lpx).height(titleHeight.lpx).textAlign(TextAlign.Center)

            Text(desc).fontSize(28.lpx).height(descHeight.lpx).maxLines(15).textOverflow(TextOverflow.Ellipsis)
        }.height(totalHeight.lpx)
    }
}


@Component
public class HouseScrollBand {
    let scroller: Scroller = Scroller()

    func build() {
        Scroll(scroller) {
            Column() {
                HouseScrollItem(title: "432 Park Avenue, New York, New York", price: 105,
                    imgSrc: @r(app.media.NewYork_NewYork_432ParkAvenue), desc: "Three years ago, this sky-high penthouse at 432 Park Avenue was the most expensive listing in New York City, going for a head-spinning $169 million. With a slew of designer furnishings by name-brand fashion houses like Fendi and Hermès, the apartment has remained on the market with a lowered asking price of $130 million since last year. Despite this, the crown jewel of the 1,400-foot Rafael Viñoly-designed tower—now listed at $105 million—continues to provide a bird’s-eye view of Central Park and beyond from its prime position along Billionaires’ Row. A private elevator landing and library are special features of the 8,225-square-foot residence, along with its six bedrooms and bathrooms and 24 windows. The home’s luxe furniture and custom piano are also emblazoned with “Penthouse 96” for distinction.")
                HouseScrollItem(title: "Sand Castle, La Jolla, California", price: 108,
                    imgSrc: @r(app.media.California_SandCastle_LaJolla), desc: "This jaw-dropping estate, created and owned by Texas-based billionaire tech entrepreneur and political donor Darwin Deason, sprawls over two parcels of oceanfront land in the seaside community of La Jolla near San Diego. Anchoring the $108 million gated spread is a seven-bedroom main home featuring a yacht-inspired bar room and a fitness center, as well as an adjoining three-bedroom guesthouse showcased by a great room flaunting a bar and a pair of 18th-century mermaid statues. Rounding it all out: a beachfront “boat bar,” several on-property caves, and gated access to La Jolla Shores Beach, as well as a private elevated beach sporting the same pristine white sand found at Georgia’s Augusta National Golf Club, where the Masters Tournament is held.")
                HouseScrollItem(title: "Bodrum, Turkey", price: 110,
                    imgSrc: @r(app.media.Turkey_Bodrum), desc: "Turkey has endured as a popular destination for folks who are considering investing in waterfront homes. So, it’s not surprising that this lavish estate built atop a hill overlooking the Mediterranean would rank as one of the most expensive properties on the market. The exact price is available only upon request, but it’s believed to be approximately $110 million. Sited in the seaside resort town of Yalikavak on the shores of the Bodrum peninsula, the ultra-modern mansion is run entirely on solar power and rests on just shy of five acres. There are 22 bedrooms in a little more than 43,000 square feet of living space boasting glitzy amenities like a sauna, steam and massage rooms, and an indoor pool. Additional highlights include a second outdoor pool flanked by a sundeck and a grassy lawn.")
                HouseScrollItem(title: "Villa Del Amor, Bel Air, California", price: 115,
                    imgSrc: @r(app.media.California_BelAir_VillaDelAmor), desc: "This custom-built estate, dubbed Villa Del Amor (House of Love) and owned by Paul L. Kessler and his wife Diana Derycz-Kessler, founders of the investment firm Bristol Capital Advisors, which operates the artisan candy company Sugarfina, was crafted by Sinclair Associates Architects with Moroccan-influenced interiors by Dejager Design. Encompassing roughly 15,000 square feet, the nine-bedroom mansion sits amid a 1.6-acre parcel nestled alongside the 13th hole of the Bel-Air Country Club golf course. In addition to vintage fireplaces and fountains culled from the couple’s European travels, highlights include a candy bar stocked with Sugarfina products, a movie theater, a private chapel, a pool and spa, a gym, and four courtyards. There’s even a 130-step staircase for outdoor workouts.")
            }.padding(left: 20.lpx, right: 20.lpx, bottom: 100.lpx)
        }.scrollable(ScrollDirection.Vertical).height(totalHeight.lpx).margin(bottom: 30.lpx)
    }
}

@Component
public class HouseScrollFixedBand {
    let scroller: Scroller = Scroller()
    @State var scrollable: ScrollDirection = ScrollDirection.Vertical
    var currentOffset: Int64 = 0
    var timer: Option<Timer> = Option<Timer>.None
    var canScroll: Bool = true

    func debounceOnScroll(yOffset: Float64) {
        if (!canScroll) {
            return
        }
        canScroll = false
        timer = Timer.once(200 * Duration.millisecond, {  =>
            onScrollCallback(yOffset)
            canScroll = true
        })
        return
    }

    func onScrollCallback(yOffset: Float64) {
        if (yOffset < 0.0 && currentOffset != 0) {
            currentOffset -= totalHeight
            scroller.scrollTo(xOffset: 0.lpx , yOffset: Float64(currentOffset).lpx)
        } else if (yOffset > 0.0 && currentOffset < totalHeight * 3) {
            currentOffset += totalHeight
            scroller.scrollTo(xOffset: 0.lpx, yOffset: Float64(currentOffset).lpx)
        }
        return
    }

    func build() {
        Scroll(scroller) {
            Column() {
                HouseScrollItem(title: "432 Park Avenue, New York, New York", price: 105,
                    imgSrc: @r(app.media.NewYork_NewYork_432ParkAvenue), desc: "Three years ago, this sky-high penthouse at 432 Park Avenue was the most expensive listing in New York City, going for a head-spinning $169 million. With a slew of designer furnishings by name-brand fashion houses like Fendi and Hermès, the apartment has remained on the market with a lowered asking price of $130 million since last year. Despite this, the crown jewel of the 1,400-foot Rafael Viñoly-designed tower—now listed at $105 million—continues to provide a bird’s-eye view of Central Park and beyond from its prime position along Billionaires’ Row. A private elevator landing and library are special features of the 8,225-square-foot residence, along with its six bedrooms and bathrooms and 24 windows. The home’s luxe furniture and custom piano are also emblazoned with “Penthouse 96” for distinction.")
                HouseScrollItem(title: "Sand Castle, La Jolla, California", price: 108,
                    imgSrc: @r(app.media.California_SandCastle_LaJolla), desc: "This jaw-dropping estate, created and owned by Texas-based billionaire tech entrepreneur and political donor Darwin Deason, sprawls over two parcels of oceanfront land in the seaside community of La Jolla near San Diego. Anchoring the $108 million gated spread is a seven-bedroom main home featuring a yacht-inspired bar room and a fitness center, as well as an adjoining three-bedroom guesthouse showcased by a great room flaunting a bar and a pair of 18th-century mermaid statues. Rounding it all out: a beachfront “boat bar,” several on-property caves, and gated access to La Jolla Shores Beach, as well as a private elevated beach sporting the same pristine white sand found at Georgia’s Augusta National Golf Club, where the Masters Tournament is held.")
                HouseScrollItem(title: "Bodrum, Turkey", price: 110,
                    imgSrc: @r(app.media.Turkey_Bodrum), desc: "Turkey has endured as a popular destination for folks who are considering investing in waterfront homes. So, it’s not surprising that this lavish estate built atop a hill overlooking the Mediterranean would rank as one of the most expensive properties on the market. The exact price is available only upon request, but it’s believed to be approximately $110 million. Sited in the seaside resort town of Yalikavak on the shores of the Bodrum peninsula, the ultra-modern mansion is run entirely on solar power and rests on just shy of five acres. There are 22 bedrooms in a little more than 43,000 square feet of living space boasting glitzy amenities like a sauna, steam and massage rooms, and an indoor pool. Additional highlights include a second outdoor pool flanked by a sundeck and a grassy lawn.")
                HouseScrollItem(title: "Villa Del Amor, Bel Air, California", price: 115,
                    imgSrc: @r(app.media.California_BelAir_VillaDelAmor), desc: "This custom-built estate, dubbed Villa Del Amor (House of Love) and owned by Paul L. Kessler and his wife Diana Derycz-Kessler, founders of the investment firm Bristol Capital Advisors, which operates the artisan candy company Sugarfina, was crafted by Sinclair Associates Architects with Moroccan-influenced interiors by Dejager Design. Encompassing roughly 15,000 square feet, the nine-bedroom mansion sits amid a 1.6-acre parcel nestled alongside the 13th hole of the Bel-Air Country Club golf course. In addition to vintage fireplaces and fountains culled from the couple’s European travels, highlights include a candy bar stocked with Sugarfina products, a movie theater, a private chapel, a pool and spa, a gym, and four courtyards. There’s even a 130-step staircase for outdoor workouts.")
            }.padding(left: 20.lpx, right: 20.lpx, bottom: 100.lpx)
        }.scrollable(scrollable).height(totalHeight.lpx)
        .onScroll({ offsetResult: OffsetResult => debounceOnScroll(offsetResult.yOffset) })
    }
}