/* Demo: every component of the system on one page, arranged as the game
   arranges them, with real prose from the seed-101 chronicle. */

import React, { useState } from "react";
import {
	TinRoot, Shell, Title, MeanderRule,
	Chronicle, SeasonHeading, Entry, Colophon,
	Panel, PanelHeading, StatusStrip, Refusal,
	Button, ButtonRow, Stack, Input,
	Stepper, SealToggle, ContractCard, Stats, Stat,
} from "../TinRoad.jsx";

export default function App() {
	const [clay, setClay] = useState(2);
	const [papyrus, setPapyrus] = useState(6);
	const [seals, setSeals] = useState(2);
	const [sealNext, setSealNext] = useState(false);
	const [signed, setSigned] = useState(false);
	const [refusal, setRefusal] = useState("");

	return (
		<TinRoot>
			<Shell
				book={
					<>
						<Title>THE TIN ROAD</Title>
						<MeanderRule />
						<Chronicle>
							<Colophon>Seed 101. Written as it happens.</Colophon>
							<SeasonHeading>The First Season</SeasonHeading>
							<Entry>In the first season of House Sapanu, Gamiradu took up the pen.</Entry>
							<Entry>House Yabninu advanced 30 shekels against the season's road —
								generously, promptly, and with the ledger of what it expected in
								return already open.</Entry>
							<Entry>At the guild hall of Ugarit, Gamiradu bought the season's pack:
								2 clay, 6 papyrus, 2 seals — 24 shekels, weighed out before the dew
								burned off.</Entry>
							<Entry>The water at the Salt Marsh took its census: 4 sheets of papyrus
								came out pulp. The clay came out streaked but legible.</Entry>
							<Entry>Gamiradu sent the ledger home from Ugarit: a single entry, a
								seal, and 4 sheets of the season's stock. The road was going badly,
								and this was the admission.</Entry>
						</Chronicle>
					</>
				}
				aside={
					<Stack>
						<StatusStrip>
							Gamiradu at the Salt Marsh — day 4 — 31 light — {clay} clay,
							{" "}{papyrus} papyrus, {seals} seals — purse 2 — next step 2 light
						</StatusStrip>

						<Panel major>
							<PanelHeading>The road</PanelHeading>
							<Stack>
								<Button tone="primary">Travel to the next node</Button>
								<SealToggle checked={sealNext} onChange={setSealNext}>
									Seal what is written next
								</SealToggle>
								<ButtonRow>
									<Button>Note</Button>
									<Button>Record</Button>
									<Button>Survey</Button>
									<Button>Treatise</Button>
								</ButtonRow>
								<Button tone="danger"
									onClick={() => setRefusal("No courier goes: it takes a seal, 4 media, and something written.")}>
									Send the ledger home by courier
								</Button>
							</Stack>
							<Refusal>{refusal}</Refusal>
						</Panel>

						<Panel>
							<PanelHeading>Outfit the season</PanelHeading>
							<Stack>
								<Stepper label="Clay" hint="cheap, heavy, survives water"
									value={clay} onChange={setClay} />
								<Stepper label="Papyrus" hint="light, ruined by water"
									value={papyrus} onChange={setPapyrus} />
								<Stepper label="Seals" hint="authenticate, or pay the courier"
									value={seals} onChange={setSeals} />
								<Stats>
									<Stat label="cost" value="24 shekels" />
									<Stat label="bulk" value="12 of 16" />
									<Stat label="treasury" value="0 + 30 advance" />
								</Stats>
								<Input placeholder="seed" defaultValue="101" />
							</Stack>
						</Panel>

						<ContractCard
							name="The storm pledge"
							holder="the temple of the storm god"
							terms="the god's hand over the bad crossings, tithed in daylight each time it is needed"
							signed={signed}
							onSign={() => setSigned(true)}
							signLabel="Sign the storm pledge"
						/>
					</Stack>
				}
			/>
		</TinRoot>
	);
}
