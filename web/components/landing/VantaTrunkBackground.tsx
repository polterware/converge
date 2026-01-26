"use client";

import Script from "next/script";
import { useEffect, useRef, useState } from "react";

const P5_URL = "https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.1.9/p5.min.js";

interface VantaTrunkBackgroundProps {
  chaos?: number;
  color?: number;
  backgroundColor?: number;
}

// Helper function to convert hex number to hex string
function color2Hex(color: number): string {
  return "#" + color.toString(16).padStart(6, "0");
}

// Check if mobile
function mobileCheck(): boolean {
  if (typeof window === "undefined") return false;
  return window.innerWidth < 768;
}

export function VantaTrunkBackground({
  chaos = 1.0,
  color = 0xff0000,
  backgroundColor = 0xffffff,
}: VantaTrunkBackgroundProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const p5InstanceRef = useRef<{ remove: () => void } | null>(null);
  const chaosRef = useRef(chaos);
  const targetChaosRef = useRef(chaos);
  const animationFrameRef = useRef<number | null>(null);
  const [p5Loaded, setP5Loaded] = useState(false);

  // Smooth interpolation function
  const lerp = (start: number, end: number, factor: number) => {
    return start + (end - start) * factor;
  };

  // Animate chaos smoothly
  useEffect(() => {
    targetChaosRef.current = chaos;

    const animate = () => {
      const current = chaosRef.current;
      const target = targetChaosRef.current;
      const diff = Math.abs(target - current);

      if (diff > 0.01) {
        // Smooth interpolation with easing
        chaosRef.current = lerp(current, target, 0.1);
        animationFrameRef.current = requestAnimationFrame(animate);
      } else {
        chaosRef.current = target;
      }
    };

    animationFrameRef.current = requestAnimationFrame(animate);

    return () => {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
      }
    };
  }, [chaos]);

  useEffect(() => {
    if (!p5Loaded || !containerRef.current) return;

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const p5 = (window as { p5?: any }).p5;
    if (!p5) return;

    // Cleanup previous instance
    if (p5InstanceRef.current) {
      p5InstanceRef.current.remove();
      p5InstanceRef.current = null;
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const sketch = (p: any) => {
      const rings = mobileCheck() ? 35 : 55;
      const dimInit = 200;
      const dimDelta = 4;

      const chaosInit = 0.2;
      const chaosDelta = 0.12;
      const chaosMag = 20;

      const ox = p.random(10000);
      let oy = p.random(10000);
      let oz = p.random(10000);

      p.setup = function () {
        p.createCanvas(containerRef.current!.clientWidth, containerRef.current!.clientHeight);
        p.strokeWeight(1);
        p.stroke(color2Hex(color));
        p.smooth();
        p.noFill();
      };

      p.draw = function () {
        // Update background color
        p.background(color2Hex(backgroundColor));
        p.clear();
        p.translate(p.width / 2, p.height / 2);
        display();
      };

      function display() {
        const currentChaos = chaosRef.current;
        oy -= 0.02;
        oz += 0.00005;
        for (let i = 0; i < rings; i++) {
          p.beginShape();
          for (let angle = 0; angle < 360; angle++) {
            const radian = p.radians(angle);
            const radius =
              currentChaos * chaosMag * getNoiseWithTime(radian, chaosDelta * i + chaosInit, oz) +
              (dimDelta * i + dimInit) +
              (i * 0 || 0);
            p.vertex(radius * p.cos(radian), radius * p.sin(radian));
          }
          p.endShape(p.CLOSE);
        }
      }

      function getNoiseWithTime(radian: number, dim: number, time: number) {
        let r = radian % p.TWO_PI;
        if (r < 0.0) {
          r += p.TWO_PI;
        }
        return p.noise(ox + p.cos(r) * dim, oy + p.sin(r) * dim, oz + time);
      }

      p.windowResized = function () {
        if (containerRef.current) {
          p.resizeCanvas(containerRef.current.clientWidth, containerRef.current.clientHeight);
        }
      };
    };

    p5InstanceRef.current = new p5(sketch, containerRef.current);

    return () => {
      if (p5InstanceRef.current) {
        p5InstanceRef.current.remove();
        p5InstanceRef.current = null;
      }
    };
  }, [p5Loaded, color, backgroundColor]);

  return (
    <>
      <Script
        src={P5_URL}
        strategy="afterInteractive"
        onLoad={() => setP5Loaded(true)}
      />
      <div
        ref={containerRef}
        id="vanta-trunk-root"
        className="absolute inset-0 z-0"
        aria-hidden
      />
    </>
  );
}
