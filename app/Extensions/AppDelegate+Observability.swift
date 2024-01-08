import Resolver
import BackbaseObservability

extension AppDelegate {
    func setupObservability() {
        let tracker = TrackerBuilder.create()
        Resolver.register { tracker }
    }
}
