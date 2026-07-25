/* The Tin Road design system — type contracts.
   Hand-maintained alongside TinRoad.jsx; `npm run build` copies this to
   dist/. Keep the two files in step. */

import * as React from "react";

/** Page ground: Night background, chrome font. Everything sits on this. */
export interface TinRootProps {
	children?: React.ReactNode;
}
export declare function TinRoot(props: TinRootProps): React.JSX.Element;

/** Two-pane layout: the book on the left, the tool on the right. */
export interface ShellProps {
	/** The chronicle pane — the centerpiece. */
	book: React.ReactNode;
	/** The side panel of controls. */
	aside: React.ReactNode;
}
export declare function Shell(props: ShellProps): React.JSX.Element;

/** Bronze page title. */
export interface TitleProps {
	children?: React.ReactNode;
}
export declare function Title(props: TitleProps): React.JSX.Element;

/** The tiled geometric border. Major pieces only — one per view. */
export declare function MeanderRule(): React.JSX.Element;

/** The book: serif prose, generous leading, selectable, never truncated. */
export interface ChronicleProps {
	children?: React.ReactNode;
}
export declare function Chronicle(props: ChronicleProps): React.JSX.Element;

/** Bronze serif season heading inside the chronicle. */
export interface SeasonHeadingProps {
	children?: React.ReactNode;
}
export declare function SeasonHeading(props: SeasonHeadingProps): React.JSX.Element;

/** One chronicle paragraph. */
export interface EntryProps {
	children?: React.ReactNode;
}
export declare function Entry(props: EntryProps): React.JSX.Element;

/** The compiler's italic aside: seed lines, attributions. */
export interface ColophonProps {
	children?: React.ReactNode;
}
export declare function Colophon(props: ColophonProps): React.JSX.Element;

/** A plaster panel with one drawn contour line. */
export interface PanelProps {
	/** Heavy contour for the view's major piece. */
	major?: boolean;
	className?: string;
	children?: React.ReactNode;
}
export declare function Panel(props: PanelProps): React.JSX.Element;

/** Bronze section label inside a panel. */
export interface PanelHeadingProps {
	children?: React.ReactNode;
}
export declare function PanelHeading(props: PanelHeadingProps): React.JSX.Element;

/** The standing facts, in verdigris: who, where, what remains. */
export interface StatusStripProps {
	children?: React.ReactNode;
}
export declare function StatusStrip(props: StatusStripProps): React.JSX.Element;

/** The world saying no, in kiln red, in words. Keep it mounted even when
 * empty so the page does not jump when a refusal arrives. */
export interface RefusalProps {
	children?: React.ReactNode;
}
export declare function Refusal(props: RefusalProps): React.JSX.Element;

/** Attempt-and-report button. Never disabled to predict the caller's rules:
 * it stays pressable and the refusal is reported in words. */
export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
	/** "primary" = bronze (the view's main act), "danger" = kiln red
	 * (couriers, seals, anything spent). */
	tone?: "default" | "primary" | "danger";
	/** Shrink-to-fit instead of full width. */
	inline?: boolean;
}
export declare function Button(props: ButtonProps): React.JSX.Element;

/** Equal-width row of buttons. */
export interface ButtonRowProps {
	children?: React.ReactNode;
}
export declare function ButtonRow(props: ButtonRowProps): React.JSX.Element;

/** Vertical flow with the standard gap. */
export interface StackProps {
	children?: React.ReactNode;
}
export declare function Stack(props: StackProps): React.JSX.Element;

/** Inset text input on plaster. */
export type InputProps = React.InputHTMLAttributes<HTMLInputElement>;
export declare function Input(props: InputProps): React.JSX.Element;

/** Outfit-desk quantity row. Bounds are the caller's business — the design
 * system never invents a gate. */
export interface StepperProps {
	label: React.ReactNode;
	/** Small dim line under the label ("cheap, heavy, survives water"). */
	hint?: React.ReactNode;
	value: number;
	onChange: (next: number) => void;
	min?: number;
	max?: number;
}
export declare function Stepper(props: StepperProps): React.JSX.Element;

/** The seal checkbox: kiln red, one-shot by convention (clear it after a
 * successful sealed act). */
export interface SealToggleProps {
	checked: boolean;
	onChange: (checked: boolean) => void;
	children?: React.ReactNode;
}
export declare function SealToggle(props: SealToggleProps): React.JSX.Element;

/** A standing contract: name, holder, data-authored terms, one act. */
export interface ContractCardProps {
	name: React.ReactNode;
	holder: React.ReactNode;
	/** The deal's words — italic serif. Author them in the house voice. */
	terms: React.ReactNode;
	/** In force: the sign action disappears and the card says so. */
	signed?: boolean;
	onSign?: () => void;
	signLabel?: React.ReactNode;
}
export declare function ContractCard(props: ContractCardProps): React.JSX.Element;

/** Row of small labelled figures. */
export interface StatsProps {
	children?: React.ReactNode;
}
export declare function Stats(props: StatsProps): React.JSX.Element;

/** One labelled figure: daylight, media, silver. */
export interface StatProps {
	label: React.ReactNode;
	value: React.ReactNode;
}
export declare function Stat(props: StatProps): React.JSX.Element;
