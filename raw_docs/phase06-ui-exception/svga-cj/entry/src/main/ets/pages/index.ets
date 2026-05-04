import { CJHybridComponentV2 } from 'cjhybridview'

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Column() {
      CJHybridComponentV2({
        library: 'ohos_app_cangjie_entry',
        component: 'Index'
      })
    }
    .height('100%')
    .width('100%')
  }
}