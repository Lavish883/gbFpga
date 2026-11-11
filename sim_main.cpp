#include <SFML/Graphics.hpp>
#include <chrono>
#include <cstdint>
#include <memory>
#include <optional>
#include <string>
#include <thread>
#include <vector>

#include "Vgb_fpga_top.h"
#include "constants.h"
#include "verilated.h"

using namespace std;
using namespace sf;

int main(int argc, char* argv[]) {
    VerilatedContext ctx;
    ctx.commandArgs(argc, argv);
    Vgb_fpga_top top(&ctx);

    // RGBA framebuffer for the SFML texture.
    vector<uint8_t> frame_buffer(SCREEN_HEIGHT * SCREEN_WIDTH * 4, 0);
    RenderWindow window(VideoMode({SCREEN_WIDTH * 3, SCREEN_HEIGHT * 3}), "Gameboy emulator");

    Texture texture(Vector2u{SCREEN_WIDTH, SCREEN_HEIGHT});
    Sprite sprite(texture);

    int dot = 0;  // dot (clock) within the current line
    int prev_ly = 0;

    using Clock = chrono::steady_clock;
    auto target_time = Clock::now();
    auto stats_start = target_time;
    int frames_rendered = 0;
    
    // Frame duration in nanoseconds based on the clock speed
    auto frame_duration = chrono::nanoseconds(70224ULL * 1'000'000'000ULL / MAIN_CLK_HZ);

    sprite.scale(Vector2f(3, 3));

    while (window.isOpen()) {
        top.clk = 1;
        top.eval();

        int ly = top.LY;
        bool frame_done = false;
        if (ly != prev_ly) {
            dot = 0;
            if (ly == 0) frame_done = true;
            prev_ly = ly;
        } else {
            dot++;
        }

        // Get the pixel, OAM takes 80 cycles, we assume that each pixel is generated in 1 cycle, not true, but good enough for now
        int col = dot - OAM_SCAN_DOTS, row = ly;
        if (col >= 0 && col < int(SCREEN_WIDTH) && row >= 0 && row < int(SCREEN_HEIGHT)) {
            uint32_t rgba = top.rgba;  // bits are {a,b,g,r};
            uint8_t* p = &frame_buffer[(row * SCREEN_WIDTH + col) * 4];
            p[0] = (rgba & 0xFF);
            p[1] = (rgba & 0xFF00) >> 8;
            p[2] = (rgba & 0xFF0000) >> 16;
            p[3] = (rgba & 0xFF000000) >> 24;
        }

        top.clk = 0;
        top.eval();

        if (!frame_done) continue;

        // Sleep until the next frame, we don't want to be too fast
        if (MAIN_CLK_HZ > 0) {
            target_time += frame_duration;
            auto now = Clock::now();
            if (target_time > now) {
                this_thread::sleep_until(target_time);
            } else if (now - target_time > chrono::milliseconds(100)) {
				// Timer way off
                target_time = now;
            }
        }

        // Show emu speed in the title
        frames_rendered++;
        auto now = Clock::now();
        double secs = chrono::duration<double>(now - stats_start).count();
        
		if (secs >= 1.0) {
            double mhz = (frames_rendered * 70224.0) / secs / 1e6;
            window.setTitle("Gameboy emulator - " + to_string(mhz).substr(0, 5) + " MHz");
            stats_start = now;
            frames_rendered = 0;
        }

        while (auto event = window.pollEvent()) {
            if (event->is<Event::Closed>()) window.close();
        }

        texture.update(frame_buffer.data());
        window.clear();
        window.draw(sprite);
        window.display();
    }

    top.final();
    return 0;
}
