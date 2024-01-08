import Foundation
import Resolver
import BackbaseObservability
import OpenTelemetryApi
import OpenTelemetrySdk
import OpenTelemetryProtocolExporterHttp
import OpenTelemetryProtocolExporterCommon
import URLSessionInstrumentation

class TelemetryManager: NSObject {

    @OptionalInjected
    var tracker: Tracker?

    func setupTelemetry() {
        configureSDK()
        startSpan()
    }

    private func configureSDK() {
        let endpoint = URL(string: "https://rum-collector.backbase.io/v1/traces")!
        let customHeader = ("BB-App-Key", "975db35b-2a6b-42d5-899f-01f40f931955")
        let sessionAttributes = ["session_id": AttributeValue.string(UUID().uuidString)]

        let configuration = OtlpConfiguration(timeout: OtlpConfiguration.DefaultTimeoutInterval, headers: [customHeader])
        let exporter = OtlpHttpTraceExporter(endpoint: endpoint, config: configuration)
        let spanProcessor = SimpleSpanProcessor(spanExporter: exporter)

        OpenTelemetry.registerTracerProvider(tracerProvider: TracerProviderBuilder()
            .add(spanProcessor: spanProcessor)
            .with(resource: Resource(attributes: sessionAttributes))
            .build())

        _ = URLSessionInstrumentation(configuration: URLSessionInstrumentationConfiguration(shouldInstrument: {
            $0.url != endpoint
        }))
    }

    private func startSpan() {
        let  tracer = OpenTelemetry.instance.tracerProvider.get(instrumentationName: "@backbase/observability",
                                                                instrumentationVersion: "1.0.0")
        tracker?.subscribe(subscriber: self, eventClass: ScreenViewEvent.self) {
            let span = tracer.spanBuilder(spanName: "screen-view").setSpanKind(spanKind: .client).setActive(true).startSpan()
            span.setAttribute(key: "screen-view", value: $0.name)
            span.end()
        }
        tracker?.subscribe(subscriber: self, eventClass: UserActionEvent.self, completion: {
            let span = tracer.spanBuilder(spanName: "user-action").setSpanKind(spanKind: .client).setActive(true).startSpan()
            span.setAttribute(key: "user-action", value: $0.name)
            span.end()
        })
    }
}
