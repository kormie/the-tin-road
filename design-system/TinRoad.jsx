/* The Tin Road — React design system.
   Import tokens.css and components.css alongside this file. Plain React,
   no dependencies. The voice of every component follows the game's rules:
   the chronicle is the centerpiece, buttons attempt and report, kiln red
   is spent only on refusals, seals, and dangerous acts. */

import React from "react";

/** Page ground: Night, chrome font, everything else sits on this. */
export function TinRoot({ children }) {
	return <div className="tin-root">{children}</div>;
}

/** Two-pane layout: the book on the left, the tool on the right. */
export function Shell({ book, aside }) {
	return (
		<div className="tin-shell">
			<div>{book}</div>
			<div>{aside}</div>
		</div>
	);
}

export function Title({ children }) {
	return <h1 className="tin-title">{children}</h1>;
}

/** The tiled geometric border. Major pieces only — one per view. */
export function MeanderRule() {
	return <hr className="tin-meander" />;
}

/** The book. Serif prose, selectable, never truncated. */
export function Chronicle({ children }) {
	return <div className="tin-chronicle">{children}</div>;
}

export function SeasonHeading({ children }) {
	return <h2 className="tin-season-heading">{children}</h2>;
}

export function Entry({ children }) {
	return <p>{children}</p>;
}

/** The compiler's italic aside: seed lines, attributions. */
export function Colophon({ children }) {
	return <p className="tin-colophon">{children}</p>;
}

/** A plaster panel with one drawn contour line. `major` earns the heavy line. */
export function Panel({ major = false, className = "", children }) {
	const classes = ["tin-panel", major ? "tin-panel--major" : "", className]
		.filter(Boolean).join(" ");
	return <section className={classes}>{children}</section>;
}

export function PanelHeading({ children }) {
	return <h3 className="tin-panel-heading">{children}</h3>;
}

/** The standing facts, in verdigris: who, where, what remains. */
export function StatusStrip({ children }) {
	return <p className="tin-status">{children}</p>;
}

/** The refusal, in kiln red, in words. Present even when empty so the
    page does not jump when the world says no. */
export function Refusal({ children }) {
	return <p className="tin-refusal" role="status">{children}</p>;
}

/** Buttons attempt and report. tone: "default" | "primary" | "danger". */
export function Button({ tone = "default", inline = false, className = "", children, ...rest }) {
	const classes = [
		"tin-button",
		tone === "primary" ? "tin-button--primary" : "",
		tone === "danger" ? "tin-button--danger" : "",
		inline ? "tin-button--inline" : "",
		className,
	].filter(Boolean).join(" ");
	return <button type="button" className={classes} {...rest}>{children}</button>;
}

export function ButtonRow({ children }) {
	return <div className="tin-button-row">{children}</div>;
}

export function Stack({ children }) {
	return <div className="tin-stack">{children}</div>;
}

export function Input(props) {
	return <input className="tin-input" {...props} />;
}

/** Outfit-desk quantity row: label, hint, minus/plus. Bounds are the
    caller's business — the design system never invents a gate. */
export function Stepper({ label, hint, value, onChange, min = 0, max = Infinity }) {
	return (
		<div className="tin-stepper">
			<span className="tin-stepper-label">
				{label}
				{hint ? <span className="tin-stepper-hint">{hint}</span> : null}
			</span>
			<Button inline aria-label={`fewer ${label}`}
				onClick={() => onChange(Math.max(min, value - 1))}>−</Button>
			<span className="tin-stepper-value">{value}</span>
			<Button inline aria-label={`more ${label}`}
				onClick={() => onChange(Math.min(max, value + 1))}>+</Button>
		</div>
	);
}

/** The seal checkbox: kiln red, one-shot by convention (the caller clears
    it after a successful sealed write). */
export function SealToggle({ checked, onChange, children }) {
	return (
		<label className="tin-seal-toggle">
			<input type="checkbox" checked={checked}
				onChange={(e) => onChange(e.target.checked)} />
			<span className="tin-seal-toggle-mark" aria-hidden="true" />
			<span>{children}</span>
		</label>
	);
}

/** A standing contract: name, holder, data-authored terms, one act. */
export function ContractCard({ name, holder, terms, signed = false, onSign, signLabel = "Sign" }) {
	return (
		<Panel className={signed ? "tin-contract tin-contract--signed" : "tin-contract"}>
			<p className="tin-contract-name">{name}</p>
			<p className="tin-contract-holder">{holder}</p>
			<p className="tin-contract-terms">{terms}</p>
			{signed ? null : <Button onClick={onSign}>{signLabel}</Button>}
		</Panel>
	);
}

/** Small labelled figures: daylight, media, silver. */
export function Stats({ children }) {
	return <div className="tin-stats">{children}</div>;
}

export function Stat({ label, value }) {
	return (
		<dl className="tin-stat">
			<dt>{label}</dt>
			<dd>{value}</dd>
		</dl>
	);
}
