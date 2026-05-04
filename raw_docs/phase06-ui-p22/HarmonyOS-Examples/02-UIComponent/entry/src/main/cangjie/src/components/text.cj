/**
 * Created on 2024/7/29
 */
package ohos_app_cangjie_entry.components
import ohos.state_manage.*
import ohos.component.*
import ohos.state_macro_manage.*

@Component
public class PageTitle{
  @Prop var content : String

  func build(){
    Text(this.content).fontSize(40).fontWeight(FontWeight.W800)
  }
}


@Component
public class PageDescription{
  @Prop var content : String

  func build(){
    Text(this.content).fontSize(24).fontWeight(FontWeight.W200)
  }
}

@Component
public class SectionTitle{
  @Prop var content : String

  func build(){
    Text(this.content).fontSize(32).fontWeight(FontWeight.W800)
  }
}

@Component
public class CodeBlock{
  @Prop var code: String

  func build(){
    Text(this.code).backgroundColor(0xe9ecef).fontWeight(FontWeight.Bold)
  }
}