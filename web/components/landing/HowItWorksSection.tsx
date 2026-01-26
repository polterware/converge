import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Timer,
  BarChart3,
  Bell,
  Palette,
  LayoutPanelLeft,
  ClipboardList,
} from "lucide-react";
import { cn } from "@/lib/utils";

const features = [
  {
    icon: Timer,
    title: "Pomodoro Timer",
    description:
      "Configurable work and break cycles: 25 min focus, 5 min short break, long break after 4 pomodoros. Automatic or manual mode between phases.",
  },
  {
    icon: BarChart3,
    title: "Statistics",
    description:
      "Pomodoro counter per day, week and month. Productivity charts for the last 14 days. Everything visible in the menu bar and dedicated tab.",
  },
  {
    icon: ClipboardList,
    title: "Session history",
    description:
      "Record of completed sessions with date, time and duration. Track your progress over time.",
  },
  {
    icon: LayoutPanelLeft,
    title: "Menu bar and compact window",
    description:
      "Timer always visible in the menu bar. Quick Start, Pause and Reset. Compact window to not interrupt your flow.",
  },
  {
    icon: Bell,
    title: "Notifications and sound",
    description:
      "Alerts at the end of work and break. Configurable sound for each type of completion.",
  },
  {
    icon: Palette,
    title: "Themes",
    description:
      "Light, dark or system appearance. Distinct colors for work and break.",
  },
] as const;

export function HowItWorksSection() {
  return (
    <section
      className={cn(
        "mx-auto min-h-[100svh] max-w-5xl px-4 py-16",
        "sm:py-24 md:py-32"
      )}
    >
      <h2 className="mb-4 text-center font-serif text-3xl font-bold tracking-tight sm:text-4xl">
        How it works
      </h2>
      <p className="mx-auto mb-12 max-w-2xl text-center text-muted-foreground">
        Native Pomodoro timer for macOS. Statistics, history and notifications
        without taking you out of the flow.
      </p>
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {features.map(({ icon: Icon, title, description }) => (
          <Card key={title} size="sm" className="flex flex-col">
            <CardHeader>
              <div className="mb-2 flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary">
                <Icon className="size-5" />
              </div>
              <CardTitle className="text-base">{title}</CardTitle>
              <CardDescription className="text-sm">{description}</CardDescription>
            </CardHeader>
          </Card>
        ))}
      </div>
    </section>
  );
}
