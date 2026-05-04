/**
 * Created on 2025/8/6
 */
package ohos_app_cangjie_entry.views

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

import ohos_app_cangjie_entry.constants.StyleConstants
import ohos_app_cangjie_entry.viewmodels.KLineViewModel

@Component
public class KLineView {
    @LocalStorageLink['kLineViewModel']
    var viewModel: KLineViewModel = KLineViewModel()

    private let renderer = KLineRenderer()
    private let scroller = Scroller()

    private let kLineContext  = CanvasRenderingContext2D(RenderingContextSettings(antialias: true))
    private let volumeContext = CanvasRenderingContext2D(RenderingContextSettings(antialias: true))

    protected override func aboutToAppear() {
        viewModel.addRedrawCallback("dailykline_and_volume") {
            drawAllCharts()
        }
    }

    func build() {
        Scroll(scroller) {
            Column {
                Canvas(kLineContext)
                    .height(StyleConstants.MAIN_CHART_HEIGHT)
                    .width(viewModel.renderContext.totalWidth)
                    .onReady {
                        drawAllCharts()
                    }

                Canvas(volumeContext)
                    .height(StyleConstants.VOLUME_CHART_HEIGHT)
                    .width(viewModel.renderContext.totalWidth)
                    .onReady {
                        drawAllCharts()
                    }
            }
        }
        .scrollBar(BarState.Off)
        .width(StyleConstants.FULL_WIDTH)
        .scrollable(ScrollDirection.Horizontal)
        .onScroll { offset =>
            viewModel.updateVisibleRange(offset.xOffset)
        }
    }

    private func drawAllCharts() {
        if (!viewModel.renderContext.fullData.isEmpty()) {
            renderer.drawKLineChart(kLineContext, viewModel.renderContext)
            renderer.drawVolumeChart(volumeContext, viewModel.renderContext)
        }
    }
}
