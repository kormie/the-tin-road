import React from "react";
import {
	MeanderRule, Title, Chronicle, Entry,
} from "@tin-road/design-system";

export const TheBorder = () => <MeanderRule />;

export const UnderTheTitle = () => (
	<>
		<Title>THE TIN ROAD</Title>
		<MeanderRule />
		<Chronicle>
			<Entry>
				The caravan cleared the gate of Ugarit at first light, 40 days of it
				bought and paid for.
			</Entry>
		</Chronicle>
	</>
);
