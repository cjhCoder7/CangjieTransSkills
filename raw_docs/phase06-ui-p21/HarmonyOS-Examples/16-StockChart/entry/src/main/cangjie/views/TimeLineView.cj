/**
 * Created on 2025/8/1
 */
package ohos_app_cangjie_entry.views

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

import ohos_app_cangjie_entry.constants.StyleConstants
import ohos_app_cangjie_entry.viewmodels.TimeLineViewModel

@Component
public class TimeLineView {
    @LocalStorageLink['timeLineViewModel']
    var viewModel: TimeLineViewModel = TimeLineViewModel()

    private let renderer = TimeLineRenderer()

    private let priceContext  = CanvasRenderingContext2D(RenderingContextSettings(antialias: true))
    private let volumeContext = CanvasRenderingContext2D(RenderingContextSettings(antialias: true))

    protected override func aboutToAppear() {
        viewModel.addRedrawCallback("timeline_and_volume") {
            drawAllCharts()
        }
    }

    func build() {
        Column {
            Canvas(priceContext)
                .height(StyleConstants.MAIN_CHART_HEIGHT)
                .width(StyleConstants.FULL_WIDTH)
                .onReady {
                    drawAllCharts()
                }

            Canvas(volumeContext)
                .height(StyleConstants.VOLUME_CHART_HEIGHT)
                .width(StyleConstants.FULL_WIDTH)
                .onReady {
                    drawAllCharts()
                }
        }
    }

    private func drawAllCharts() {
        if (!viewModel.renderContext.fullData.isEmpty()) {
            renderer.drawPriceChart(priceContext, viewModel.renderContext)
            renderer.drawVolumeChart(volumeContext, viewModel.renderContext)
        }
    }
}
