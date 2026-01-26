//
//  convergeTests.swift
//  convergeTests
//
//  Created by Erick Barcelos on 25/01/26.
//

import Testing
@testable import converge

struct convergeTests {

    @Test @MainActor func pomodoroTimerStartsIdle() async throws {
        let timer = PomodoroTimer()
        #expect(timer.phase == .idle)
        #expect(timer.remainingSeconds == 25 * 60)
    }

}
