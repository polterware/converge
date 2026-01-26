declare global {
  interface Window {
    THREE?: unknown;
    VANTA?: {
      HALO: (options: {
        el: HTMLElement | string;
        THREE?: unknown;
        mouseControls?: boolean;
        touchControls?: boolean;
        gyroControls?: boolean;
        minHeight?: number;
        minWidth?: number;
        baseColor?: number;
        backgroundColor?: number;
        xOffset?: number;
        yOffset?: number;
        size?: number;
      }) => { destroy: () => void };
      TRUNK: (options: {
        el: HTMLElement | string;
        mouseControls?: boolean;
        touchControls?: boolean;
        gyroControls?: boolean;
        minHeight?: number;
        minWidth?: number;
        scale?: number;
        scaleMobile?: number;
        color?: number;
        backgroundColor?: number;
        spacing?: number;
        chaos?: number;
      }) => { destroy: () => void };
    };
  }
}

export {};
