import { HeroSection } from "@/components/landing/HeroSection";
import { HowItWorksSection } from "@/components/landing/HowItWorksSection";
import { WhyDesktopSection } from "@/components/landing/WhyDesktopSection";
import { DownloadSection } from "@/components/landing/DownloadSection";

export default function Page() {
  return (
    <main>
      <HeroSection />
      <HowItWorksSection />
      <WhyDesktopSection />
      <DownloadSection />
    </main>
  );
}
